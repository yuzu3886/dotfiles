vim9script

const AFTER_IDX: number = ((): number => {
  const rtp = &runtimepath->split(',')
  return match(rtp, '[/\\]after') - len(rtp)
})()
const PLUGIN_DIR: string = expand('~/.cache/vimp')
const MAX_JOBS: number = 4

var plugins: dict<dict<any>> = {}

def InsertPath(plugin: dict<any>)
  if isdirectory(plugin.dir)
    final rtp = &runtimepath->split(',')
    const dir = fnamemodify(plugin.dir, ':~')
    insert(rtp, dir, index(rtp, $VIMRUNTIME))
    if isdirectory($'{plugin.dir}/after')
      insert(rtp, $'{dir}/after', AFTER_IDX)
    endif
    &runtimepath = join(rtp, ',')
  endif
enddef

def AddRemotePlugin(src: string, opt: dict<any>)
  final plugin = copy(opt)
  plugin.src = src
  if get(plugin, 'name', '') == ''
    plugin.name = src->split('/')[-1]->substitute('\.git$', '', '')
  endif
  plugin.dir = $'{PLUGIN_DIR}/{plugin.name}'

  InsertPath(plugin)

  plugins[plugin.name] = plugin
enddef

def AddLocalPlugin(src: string)
  final plugin = {
    src: '',
    name: src->split('/')[-1],
    dir: expand(src),
  }

  InsertPath(plugin)

  plugins[plugin.name] = plugin
enddef

def GetRevision(dir: string): string
  const gitdir = $'{dir}/.git'
  try
    const head = readfile($'{gitdir}/HEAD')[0]
    if head !~# '^ref: '
      return head
    endif
    const ref_file = $'{gitdir}/{head[5 :]}'
    if filereadable(ref_file)
      return readfile(ref_file)[0]
    endif
  catch
  endtry
  return ''
enddef

def CloneCmd(plugin: dict<any>): list<string>
  return ['git', 'clone', '--quiet', '--depth=1', plugin.src, plugin.dir]
enddef

def PullCmd(plugin: dict<any>): list<string>
  return ['git', '-C', plugin.dir, 'pull', '--quiet', '--ff-only']
enddef

def RunJobs(targets: list<dict<any>>, BuildCmd: func(dict<any>): list<string>): list<dict<any>>
  final queue = copy(targets)
  final failures: list<dict<any>> = []
  var active = 0

  def Start(plugin: dict<any>)
    final errors: list<string> = []
    active += 1
    const job = job_start(BuildCmd(plugin), {
      env: { GIT_TERMINAL_PROMPT: '0' },
      err_cb: (_, msg: string) => {
        if msg != ''
          add(errors, msg)
        endif
      },
      exit_cb: (_, status: number) => {
        active -= 1
        if status != 0
          add(failures, { name: plugin.name, errors: errors })
        endif
      },
    })
    if job_status(job) == 'fail'
      active -= 1
      add(failures, { name: plugin.name, errors: ['job_start() failed'] })
    endif
  enddef

  while active > 0 || !empty(queue)
    while active < MAX_JOBS && !empty(queue)
      Start(queue->remove(0))
    endwhile
    sleep 10m
  endwhile
  return failures
enddef

def Report(action: string, failures: list<dict<any>>, details: list<string> = [])
  if empty(failures)
    echomsg $'{action} completed' .. (empty(details) ? '' : $' ({join(details, ', ')})')
    return
  endif

  echohl ErrorMsg
  for failure in failures
    echomsg $'failed to {action} {failure.name}'
    for line in failure.errors
      echomsg $'  {line}'
    endfor
  endfor
  echomsg $'{action} completed ({join(details + [$'{len(failures)} failed'], ', ')})'
  echohl None
enddef

export def Add(src: string, opt: dict<any> = {})
  if src =~# '\v^(https|git)'
    AddRemotePlugin(src, opt)
  else
    AddLocalPlugin(src)
  endif
enddef

export def Install()
  const targets = plugins->values()->filter((_, p) => !isdirectory(p.dir))
  if empty(targets)
    echomsg 'nothing to install'
    return
  endif

  echo 'installing plugin...'
  redraw
  Report('install', RunJobs(targets, CloneCmd))
enddef

export def Update()
  const targets = plugins->values()->filter((_, p) => !empty(p.src) && isdirectory(p.dir))
  if empty(targets)
    echomsg 'nothing to update'
    return
  endif

  const revs = targets->mapnew((_, p) => GetRevision(p.dir))

  echo 'updating plugin...'
  redraw
  const failures = RunJobs(targets, PullCmd)

  const failed = failures->mapnew((_, f) => f.name)
  var updated = 0
  for [i, plugin] in targets->items()
    if index(failed, plugin.name) < 0 && GetRevision(plugin.dir) != revs[i]
      echomsg $'updated {plugin.name}'
      updated += 1
    endif
  endfor

  Report('update', failures, [$'{updated} updated'])
enddef

export def Check(): bool
  return plugins->values()->indexof((_, p) => !empty(p.src) && !isdirectory(p.dir)) >= 0
enddef

export def Has(name: string): bool
  return has_key(plugins, name)
    && plugins[name].dir->expand()->isdirectory()
    && &runtimepath->split(',')->index(plugins[name].dir) >= 0
enddef
