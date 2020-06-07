img: 
	make leaf.img

leaf_ipl.bin: leaf_ipl.s
	nasm -f bin leaf_ipl.s  -o leaf_ipl.bin -l leaf_ipl.lst

leaf.img: leaf_ipl.bin
	dd if=leaf_ipl.bin of=leaf.img

clean:
	rm -rf *.img *.bin