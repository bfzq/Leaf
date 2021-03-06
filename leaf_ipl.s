;; 读入两个磁面，每个磁面10个柱面，18个扇区内容到内存0x0820位置
CYNM    EQU    10    ;柱面数量
MHNM    EQU    2     ;磁头数量
SECNM   EQU    18    ;扇区数量

ORG    0x7c00        ;软盘程序装载到0x7c00地址

JMP   entry
DB    0x90
DB      "LEAF-IPL"      ; 启动区的名字，可以任意字符串，7个字节
DW      512             ; 每个扇区的大小（必须是512字节）
DB      1               ; 簇的大小，必须一个扇区
DW      1               ; FAT的起始位置，一般第一个扇区开始
DB      2               ; FAT的个数，必须是2
DW      224             ; 根目录大小，一般224项
DW      2880            ; 磁盘大小，必须2880扇区
DB      0xf0            ; 磁盘种类，必须0xf0
DW      9               ; FAT长度，必须9扇区
DW      18              ; 一个磁道有几个扇区，必须18个
DW      2               ; 磁头数，必须2个
DD      0               ; 不使用分区，必须是0
DD      2880            ; 重写一次磁盘大小
DB      0,0,0x29        ; 固定值
DD      0xffffffff      ; 可能是卷标号码
DB      "Leaf!OS    "   ; 磁盘名字，11字节
DB      "FAT12   "      ; 磁盘格式名字，8字节
RESB    18              ; 空出18字节

entry:
;;初始化
    MOV   AX,0      ;AX 累加寄存器。当前指令和后面几条指令都是 初始化寄存器
    MOV   SS,AX     ;SS 栈段寄存器
    MOV   SP,0x7c00 ;SP 栈指针寄存器
    MOV   DS,AX     ;DS 数据段寄存器
;; 定义软盘内容装载内存地址
    MOV   AX,0x0820
    MOV   ES,AX     ;ES 附加段寄存器, 地址高位
    MOV   BX,0      ; 地址低位
;;定位软盘读取位置
    MOV   DH,0      ;磁头0
    MOV   CH,0      ;柱面0
    MOV   CL,2      ;扇区2,第1个扇区转载了启动程序ipl
    MOV   DL,0x00   ; 0号驱动器，第0个软盘,0x00:打印msg,0x01(不存在的软盘)打印msg_e
;;预设读取指令和读取大小
readloop:
    MOV   BX,0
    MOV   DL,0x00
    MOV   AH,0x02   ; 读取磁盘的指令
    MOV   AL,1      ; 读取1个扇区
;;调用BIOS执行指令
    INT   0x13      ;BIOS执行上述指令
    JC    error
    
    MOV   AX,ES
    ADD   AX,0x0020
    MOV   ES,AX

    ADD   CL,1
    CMP   CL,SECNM  ;比较扇区数量
    JBE   readloop  ; 不高于跳转 <=

    MOV   CL,1
    ADD   DH,1
    CMP   DH,MHNM   ;比较磁头数量
    JB   readloop   ; JB 低于，跳转 <

    MOV   DH,0
    ADD   CH,1
    CMP   CH,CYNM
    JB   readloop

    MOV   SI,msg    ;SI 源变址寄存器 SI=msg

;; 打印信息
putloop:
    MOV   AL,[SI]   ; AL 累加寄存器低位
    ADD   SI,1      ; SI 累加，一个字符一个字符显示
    CMP   AL,0
    JE    fin
    MOV   AH,0x0e   ; AH 累加寄存器高位 显示一个字符
    MOV   BX,15     ; BX 基址寄存器，指定字符颜色
    INT   0x10      ; CPU中断，调用BIOS显卡
    JMP   putloop

fin:
    HLT           ; CPU等待指令
    JMP   fin       ; 跳转到fin

error:
    MOV   SI,msg_e    ;SI 源变址寄存器 SI=msg
    JMP   putloop

msg:
    DB    0x0a, 0x0a    ; 0x0a表示换行字符
    DB    "hello, world"
    DB    0x0a      ; 换行
    DB    0

msg_e:
    DB    0x0a, 0x0a    ; 0x0a表示换行字符
    DB    "load leaf error"
    DB    0x0a      ; 换行
    DB    0

    RESB  0x7dfe-($-$$)   ; 当前地址到0x7dfe填充0x00

    DB    0x55, 0xaa