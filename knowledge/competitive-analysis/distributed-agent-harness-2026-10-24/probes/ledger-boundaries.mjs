// Dependency-free boundary probe. Argument: inspected Harness Remote checkout.
import assert from 'node:assert/strict';
import {mkdtemp, rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const root = path.resolve(process.argv[2]);
const {SessionOperationLedger, runIdempotentMutation} = await import(pathToFileURL(path.join(root,'bridge/src/session-operation-ledger.js')));
const dir = await mkdtemp(path.join(tmpdir(),'cms-ledger-boundary-'));
const identity = {agentID:'fake-provider',sessionID:'fake-session',clientRequestId:'op-1'};
try {
  const a = new SessionOperationLedger({machineID:'fake-machine',stateDirectory:dir});
  const b = new SessionOperationLedger({machineID:'fake-machine',stateDirectory:dir});
  // Both instances cache absence before one writes. No parallel OS processes are claimed.
  await a.get(identity); await b.get(identity);
  const first = await a.begin({...identity,signature:'same'});
  const second = await b.begin({...identity,signature:'same'});
  assert.equal(first.duplicate,false); assert.equal(second.duplicate,false);
  console.log(JSON.stringify({probe:'two_independent_cached_ledger_instances',firstDuplicate:first.duplicate,secondDuplicate:second.duplicate,conclusion:'not a multi-instance lease'}));
  let effects = 0;
  const id2 = {...identity,clientRequestId:'op-2'};
  for (let i=0;i<2;i++) {
    await assert.rejects(runIdempotentMutation({operationLedger:a,identity:id2,signature:'same',dispatch:async()=>{effects++;throw new Error('response lost after simulated side effect, no ambiguous flag');}}));
  }
  assert.equal(effects,2);
  console.log(JSON.stringify({probe:'unmarked_ambiguous_adapter_error',simulatedSideEffects:effects,conclusion:'adapter must explicitly classify uncertain dispatch failures'}));
} finally { await rm(dir,{recursive:true,force:true}); }
