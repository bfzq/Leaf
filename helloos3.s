; hello-os
; TAB=4

ORG		0x7c00			;软盘程序装载到0x7c00地址

; 以下は標準的なFAT12フォーマットフロッピーディスクのための記述

JMP		entry
DB		0x90
DB		"HELLOIPL" ;启动扇区的名字,只能8个字节
DW		512				; 1セクタの大きさ（512にしなければいけない）
DB		1				; クラスタの大きさ（1セクタにしなければいけない）
DW		1				; FATがどこから始まるか（普通は1セクタ目からにする）
DB		2				; FATの個数（2にしなければいけない）
DW		224				; ルートディレクトリ領域の大きさ（普通は224エントリにする）
DW		2880			; このドライブの大きさ（2880セクタにしなければいけない）
DB		0xf0			; メディアのタイプ（0xf0にしなければいけない）
DW		9				; FAT領域の長さ（9セクタにしなければいけない）
DW		18				; 1トラックにいくつのセクタがあるか（18にしなければいけない）
DW		2				; ヘッドの数（2にしなければいけない）
DD		0				; パーティションを使ってないのでここは必ず0
DD		2880			; このドライブ大きさをもう一度書く
DB		0,0,0x29		; よくわからないけどこの値にしておくといいらしい
DD		0xffffffff		; たぶんボリュームシリアル番号
DB		"HELLO-OS   "	; ディスクの名前（11バイト）
DB		"FAT12   "		; フォーマットの名前（8バイト）
RESB	18				; とりあえず18バイトあけておく

; プログラム本体

entry:
    MOV		AX,0			;AX 累加寄存器
    MOV		SS,AX     ;SS 栈段寄存器
    MOV		SP,0x7c00 ;SP 栈指针寄存器
    MOV		DS,AX     ;DS 数据段寄存器
    MOV		ES,AX     ;ES 附加段寄存器

    MOV		SI,msg    ;SI 源变址寄存器
putloop:
    MOV		AL,[SI]   ; AL 累加寄存器低位
    ADD		SI,1			; SI 累加，一个字符一个字符显示
    CMP		AL,0
    JE		fin
    MOV		AH,0x0e		; AH 累加寄存器高位
    MOV		BX,15			; BX 基址寄存器
    INT		0x10			; CPU中断，调用BIOS显卡
    JMP		putloop
fin:
    HLT						; 何かあるまでCPUを停止させる
    JMP		fin				; 無限ループ

msg:
    DB		0x0a, 0x0a		; 改行を2つ
    DB		"hello, world"
    DB		0x0a			; 改行
    DB		0

    RESB	0x7dfe-$		; 0x7dfeまでを0x00で埋める命令

    DB		0x55, 0xaa

; 以下はブートセクタ以外の部分の記述

    DB		0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
    RESB	4600
    DB		0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
    RESB	1469432
