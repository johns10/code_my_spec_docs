"""Native installed Codex protocol handshake only; no sessions, prompts or credential reads."""
import json, subprocess, selectors, time
p = subprocess.Popen(['codex','app-server','--stdio'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
s = selectors.DefaultSelector(); s.register(p.stdout, selectors.EVENT_READ)
try:
    p.stdin.write(json.dumps({'id':1,'method':'initialize','params':{'clientInfo':{'name':'cms_research_probe','version':'0.1'},'capabilities':{'experimentalApi':True}}})+'\n');p.stdin.flush()
    deadline=time.monotonic()+15
    result={'probe':'native_codex_initialize','status':'timeout','sessions_created':0,'model_turns':0}
    while time.monotonic()<deadline:
        if not s.select(timeout=.5):
            if p.poll() is not None:
                result['status']='process_exited'; result['exit_code']=p.returncode;break
            continue
        line=p.stdout.readline()
        if not line: break
        try: message=json.loads(line)
        except json.JSONDecodeError: continue
        if message.get('id')==1:
            result['status']='success' if 'result' in message else 'error'
            result['result_fields']=sorted(message.get('result',{}).keys())
            if 'error' in message: result['error_code']=message['error'].get('code')
            break
    print(json.dumps(result))
finally:
    s.close();p.terminate()
    try:p.wait(timeout=3)
    except subprocess.TimeoutExpired:p.kill();p.wait()
