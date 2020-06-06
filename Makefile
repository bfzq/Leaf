img: 
	make leaf.img

ipl.bin: ipl.s
	nasm -f bin ipl.s  -o ipl.bin -l ipl.lst

leaf.img: ipl.bin
	dd if=ipl.bin of=ipl.img

clean:
	rm -rf *.img *.bin