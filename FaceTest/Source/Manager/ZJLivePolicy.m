//
//  ZJLivePolicy.m
//  ECFaceSDK
//
//  Created by cocoa on 2020/1/7.
//  Copyright © 2020 dev.keke@gmail.com. All rights reserved.
//

#import "ZJLivePolicy.h"

#define FALSE 0
#define TRUE 1
typedef int JBOOL;


#include <stdio.h>
#include <stdlib.h>

//using namespace std;

// 动作定义
#define        MOVE_EYE                1    // 眨眼
#define        MOVE_MOUTH                2    // 张嘴
#define        MOVE_YAW                3    // 左右转头
#define        MOVE_NOD                4    // 抬低头

// 初始状态值
#define        STATE_NONE        -100

// 最小值赋值
#define        ASSIGN_MIN(sMin, sCur)    \
if (sMin == STATE_NONE)\
{\
sMin = sCur; \
}\
else if (sCur < sMin)\
{\
sMin = sCur; \
}

// 最大值赋值
#define        ASSIGN_MAX(sMax, sCur)    \
if (sMax == STATE_NONE)\
{\
sMax = sCur; \
}\
else if (sCur > sMax)\
{\
sMax = sCur; \
}

// 动作编号
int m_nMove = 0;            // 当前正在检测的动作

// 阈值
int m_nThreshold = 0;

// 以下两值用于判断简单动作 1-6
int m_nMax;                //
int m_nMin;

// 以下两值用于判断复杂动作 7-8
int m_nNegMax;            // 左最大值
int m_nPosMax;            // 右最大值



// 开始检测某动作（动作编码+阈值）
void ZJ_Init(int nMove, int nThreshold)
{
    m_nMove = nMove;
    m_nThreshold = nThreshold;
    m_nMax = STATE_NONE;        // 状态清空
    m_nMin = STATE_NONE;
    m_nNegMax = STATE_NONE;
    m_nPosMax = STATE_NONE;
}

void ZJ_UpdateState_Simple(int nCur)
{
    // 最小值赋值
    ASSIGN_MIN(m_nMin, nCur);
    
    // 最大值赋值
    ASSIGN_MAX(m_nMax, nCur);
}
// [复杂动作] 利用两个方向的状态值
void ZJ_UpdateState_Complex(int nCur)
{
    if (nCur < 0) // 更新左转最大值
    {
        ASSIGN_MAX(m_nNegMax, nCur);
    }
    else if (nCur > 0) // 更新右转最大值
    {
        ASSIGN_MAX(m_nPosMax, nCur);
    }
}

//=-----------------------------------------------------
// 判断简单动作是否出现
JBOOL ZJ_IsMove_Simple()
{
    if (m_nMax != STATE_NONE && m_nMin != STATE_NONE)
    {
        //printf("max=%d min=%d m_nMove=%d throd=%d\n",m_nMax,m_nMin,m_nMove,m_nThreshold);
        if (m_nMax - m_nMin >= m_nThreshold)
            return TRUE;
    }
    
    return FALSE;
}
// 判断复杂动作是否出现
JBOOL ZJ_IsMove_Complex()
{
    if (m_nNegMax != STATE_NONE && m_nPosMax != STATE_NONE)
    {
        if (m_nNegMax + m_nPosMax >= m_nThreshold)
            return TRUE;
    }
    
    return FALSE;
}


@implementation ZJLivePolicy

+ (void)reset{
    m_nMove = 0;
}

+ (BOOL)detectLive:(int)nMove threshold:(int )nThreshold cur:(int )nCur{
    JBOOL bRet = FALSE;
    //----------------------------------------
    
    // 如果是新动作，则需清空状态
    if (m_nMove == 0 || m_nMove != nMove)
    {
        // 新动作，初始化缓存
        ZJ_Init(nMove, nThreshold);
    }
    
    ZJ_UpdateState_Simple( nCur);
    bRet = ZJ_IsMove_Simple();

    //----------------------------------------
    return bRet;
}

@end
