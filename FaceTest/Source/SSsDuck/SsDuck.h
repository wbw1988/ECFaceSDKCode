/*=///////////////////////////////////////////////////////////////////////=*/
/*= SsDuck.h : main header file for the 视频内目标追踪 algorithms DLL     =*/
/*=///////////////////////////////////////////////////////////////////////=*/

#if !defined(__SCK_SSDUCK_H__9165EC66__E2590D86DF3A__INCLUDED_ZNN__)
#define __SCK_SSDUCK_H__9165EC66__E2590D86DF3A__INCLUDED_ZNN__

/*=///////////////////////////////////////////////////////////////////////=*/
/*= 本库的接口类型，及返回的错误码定义，>=0时为成功，可表示特定意义       =*/
/*=///////////////////////////////////////////////////////////////////////=*/
//#include "PackLock.h"
/* 函数API接口的返回值：>=0为成功(还可以表示长度等标识)，<0为失败值 */
#ifndef SSY_SUCC
#define IsWell(r)				((r) >= 0)			/* 是否OK啦 */

#define SSY_SUCC				0					/* 成功操作 */
#define SSY_FAIL				-1					/* 失败结果 */
#define SSY_ERRO				-2					/* 校验错误 */
#define SSY_PARA				-3					/* 参数错误 */
#define SSY_EMPT				-4					/* 空特征库 */
#define SSY_NOFP				-5					/* 未按或孬 */
#define SSY_NSAM				-6					/* 值不相关 */
#define SSY_NMAT				-7					/* 值不匹配 */
#define SSY_NMEM				-8					/* 内存不足 */
#define SSY_FLSH				-9					/* 有闪存错 */
#define SSY_NODV				-10					/* 传感器错 */
#define SSY_TOLV				-11					/* 请抬起手 */
#define SSY_NSUP				-12					/* 不支持令 */
#define SSY_TMOT				-13					/* 操作超时 */
#define SSY_BUSY				-14					/* 我很忙啊 */
#define SSY_NLNK				-15					/* 设备断开 */
#define SSY_LESS				-16					/* 特点过少 */
#define SSY_CNCL				-17					/* 取消操作 */
#define SSY_FILE				-18					/* 文件错误 */

#define LIC_NONE				-19					/* 狗狗不在 */
#define LIC_TMOT				-20					/* 狗已老啦 */
#define LIC_BIND				-21					/* 狗非本属 */
#define LIC_DEAT				-22					/* 许可已销 */
#define LIC_NMCN				-23					/* 无机器码 */
#define LIC_DISK				-24					/* 无权IO盘 */

#define LIC_TIME				-26					/* 时间过期 */

#define SASO_DEAD				-120				/* 该急救啦 */

#define lmtMin(v, th)	if((v) < (th)) (v) = (th)	/* 限定最小值 */
#define lmtMax(v, th)	if((v) > (th)) (v) = (th)	/* 限定最大值 */
#define lmtLmt(v, n, x)	lmtMin(v, n); lmtMax(v, x)	/* 限定区间值 */

#define setBit(v, b)	(v) |= (1 << (b))			/* 置1指定bit */
#define clrBit(v, b)	(v) &= (~(1 << (b)))		/* 清0指定bit */
#define getBit(v, b)	(((v) & (1 << (b))) != 0)	/* 取?指定bit */

#define MAX_B64(sz)		(((sz) + 2) / 3 * 4)		/* BASE64长 */

#endif /* #ifndef SSY_SUCC */

/*===============================================================*/

/* 追踪目标属性标识定义，若标识值>10000，则表示该属性计算量较大 */
#define TD_POSE					0					/* 头部3D姿态 */
#define TD_RECT					1					/* 矩形位置   */
#define TD_SCOR					3					/* 人脸置信度 */
#define TD_FCID					4					/* 人脸FaceId */
#define TD_EYED					6					/* 眼睛张开程度 */
#define TD_MOTD					8					/* 嘴巴张开程度 */
#define TD_ETAT					10					/* 靠靠  */
#define TD_PCNT					11					/* 点的总数量 */

#define TD_PLOC				10006				/* 点的坐标   */
#define TD_SHRP				10007				/* 图像清晰度 */
#define TD_HACK             10008               /* 静默检活   */
#define TD_COVER            10009               /* 遮挡口罩墨镜判断   */
#define TD_FSPF             10010               /* 活体hack检测 */

/*===============================================================*/

/* 微软文档说__declspec(dllexport)和.DEF只用一个即可，但前者 */
/* 在32下有_前缀，在64位下无，后者则均无_前缀，故用.DEF兼顾 */
#ifdef _MSC_VER
#ifdef __cplusplus
#define SAS_API(type) extern "C" type __stdcall
#else
#define SAS_API(type) type __stdcall
#endif
#else /* NOT _MSC_VER */
#ifdef __cplusplus
#define SAS_API(type) extern "C" __attribute__((visibility("default"))) type
#else
#define SAS_API(type) __attribute__((visibility("default"))) type
#endif
#endif /* -fvisibility=hidden -m64 -fPIC -shared */

extern int iosSsDuckLic;

/*=///////////////////////////////////////////////////////////////////////=*/
/*= 对外的接口有：版本信息、句柄打开、句柄关闭、图像获取、状态查询等功能  =*/
/*=///////////////////////////////////////////////////////////////////////=*/

/* 接口：负责数据初始化操作，在使用其它接口前调用 */
SAS_API(int) SsSetDatFile
					(
					const char *szFileName,			/* 模型全文件名 */
					int nReserved,					/* 保留用请给零 */
					int nOptCfg						/* 附加的配置值 */
					);

/*===============================================================*/
/* 接口：按类型号，获取信息串，返回模板的最大字节长度，<0失败 */
/* 说明：0=本库版本，1=模型文件版本 */
SAS_API(int) SsMobiVersn
					(
					int nType,						/* 信息配置类型 */
					char *szInfo/*[1024+1]*/		/* 配置IO字符串 */
					);

/*===============================================================*/

SAS_API(int) SsMobiLicIsOk
(
 const char *szFile,            /* 解析许可，由Mode定义   */
 int nMode,                     /* 模式：0=文件，>0内容长  */
 const char *szFilter           /* 目标字符串儿，含通配符  */
 );
/*===============================================================*/
SAS_API(int) SsMobiDinit
					(
					void **phEnvSet,				/* 环境句柄地址 */
					int nWd, int nHi,				/* 目标图宽和高 */
					int nCmo,
                    const unsigned char *hTpls,
					int *hOptCfg					/* 请固定给NULL */
					);

/*===============================================================*/

/* 接口：结束算法过程，并释放所用的环境资源，<0失败 */
/* 说明：在一种过程完成后，必须调用此释放，以免内存泄露 */
SAS_API(int) SsMobiDexit
					(
					void *hEnvSet					/* 环境句柄地址 */
					);

/*===============================================================*/

/* 接口：对图像宽高1/8下采样，变小图输出，暂不支持 */		
SAS_API(int) SsMobiSmall
					(
					int nType,						/* 预览变小类型 */
					const unsigned char *hImg,		/* 压入图像数据 */
					unsigned char *hOut,			/* 输出预览小图 */
					void *hEnvSet					/* 环境句柄地址 */
					);

/*===============================================================*/

/* 接口：向算法推送压入一帧图像，供算法处理，<0失败 */
/* 返回：当前帧处理得到的目标的个数，用于nDatRef指定 */
/* 说明：bContinue置1, 继续追踪，否则0=重新检测当前帧 */
SAS_API(int) SsMobiFrame
					(
					const unsigned char *hImg,		/* 压入图像数据 */
                    int nRotation,                    /* 顺时针旋转角 */
					int bcontinue,					/* 顺时针旋转角 */
					void *hEnvSet					/* 环境句柄地址 */
					);

/*===============================================================*/

/* 接口：获取压入图像后的各种状态结果，并收集数据，<0失败 */
SAS_API(int) SsMobiIsoGo
					(
					int nIndex,						/* JWM_属性ID号 */
					int *hGoDat,					/* 返回数据内存 */
					int nDatRef,					/* 目标的索引号 */
                    int nOptCfg,                    /* 附加的配置值 */
					void *hEnvSet					/* 环境句柄地址 */
					);

/*=///////////////////////////////////////////////////////////////////////=*/

#endif /* !(__SCK_SSDUCK_H__9165EC66__E2590D86DF3A__INCLUDED_ZNN__) */

/*=///////////////////////////////////////////////////////////////////////=*/
/*= The end of this file. =*/
