img: 
	make leaf.img

ipl.bin: ipl2.s
	nasm -f bin ipl2.s  -o ipl.bin -l ipl.lst

leaf.img: ipl.bin
	dd if=ipl.bin of=ipl.img

clean:
	rm -rf *.img *.bin