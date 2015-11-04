/***********************************************************************
 	graphgpu
	Authors: Koichi Shirahata, Hitoshi Sato, Toyotaro Suzumura, and Satoshi Matsuoka

This software is licensed under Apache License, Version 2.0 (the  "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
***********************************************************************/

#ifndef __REDUCE2_CU__
#define __REDUCE2_CU__

#include "MarsInc.h"
#include "global.h"

//#define _DEBUG_REDUCE

__device__ void REDUCE_COUNT_FUNC2//(void* key, void* vals, size_t keySize, size_t valCount)
{
  EMIT_COUNT_FUNC(sizeof(int), sizeof(CC2_OUTVAL_T));
}

__device__ void REDUCE_FUNC2//(void* key, void* vals, size_t keySize, size_t valCount)
{
  int i;
  int cur_min_nodeid = -1;
  int self_min_nodeid = -1;
  
  for(i = 0; i < valCount; i++) {
    CC_VAL_T* iVal = (CC_VAL_T*)GET_VAL_FUNC(vals, i);
    int cur_nodeid = -1;

    cur_nodeid = iVal->dst;
    if(iVal->is_v == true) { // for calculating indivisual diameter
      self_min_nodeid = cur_nodeid;
    }
    if(cur_min_nodeid == -1) {
      cur_min_nodeid = cur_nodeid;
    } else {
      if(cur_nodeid < cur_min_nodeid)
	cur_min_nodeid = cur_nodeid;
    }
  }

  CC2_OUTVAL_T* o_val = (CC2_OUTVAL_T*)GET_OUTPUT_BUF(0);
  if(self_min_nodeid == cur_min_nodeid) {
    o_val->is_changed = false;
  } else 
    o_val->is_changed = true;
  o_val->dst = cur_min_nodeid;

  EMIT_FUNC(key, o_val, sizeof(int), sizeof(CC2_OUTVAL_T));
}

#endif //__REDUCE2_CU__
