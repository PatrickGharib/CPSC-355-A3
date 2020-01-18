//File:assignment 3
//Author: Patrick Abou Gharib
//Date:October 27, 2017
//description: ARMv8 assembly language program that implents an insertion sort algorithm
//randomly generates an array and prints values generated, insertion sorts the array and
// then prints the sorted list to the screen

array:		.string "v[%d]: %d\n"
sorted_array:	.string "\nSorted array: \n"

	define(arraybase, x28)                  //define arraybase for reg x28
	size = 50				//set size of array
	array_size = size*4                     //set size of array
        j_size = 4                              //size of j 
        i_size = 4                              //size of i 
        temp_size = 4			        //size of temp
	index_i = 216				//memory address of index i
	index_j = 220 				//memory address of index j
	temp_s = 224                            //memory address of temp    
        array_offset = 16   			//base address of the array
	i_offset = array_offest + array_size    //calculate i offset
        j_offset = i_offset + j_size            //calculate j offest
        temp_offset = j_offset + j_size         //temp offset 
                                                
                                                //calculate total variable offset
        variable_offset = array_size + i_size + j_size + temp_size
        


        alloc = -(16 + variable_offset) &  -16  //alloc memory for all variables required
	dealloc = -alloc			//used to deallocate the memory
	
	fp .req x29				//register equate
	lr .req x30				//register equate
	
	.balign 4				//quadword align instructions
	.global main				//allow main label to be visible 
main:
	stp	x29, x30, [sp, alloc]!		//allocate memory 
	mov 	fp, sp				//fp .req x29
	add	arraybase, fp, array_offset		//calculate the arraybase address
	
	mov	w21, 0				//set i=0
	str 	w21, [fp, index_i]		//write i to stack

loop_one:	
	bl 	rand				//generate random numbers 
	ldr 	w21, [fp, index_i]		//read i from the stack
	and 	w22, w0, 0xFF		        //and comparison of rand() and 0xFF 
	str 	w22, [arraybase, w21, sxtw 2]	//write the random number gen. to the stack at index i
	ldr 	w21, [fp, index_i]		//read i from the index

	
print_one:
	adrp	x0, array			//set x0 pointer to addr. of array string
	add	w0, w0, :lo12:array		//put the contents of array string in x0
	mov 	w1, w21				//set arg 2 to w21
	mov 	w2, w22			        //set arg 3 to w22
	bl 	printf				//print array string

	add	w21, w21, 1				//increment i by 1 
	str 	w21, [fp, index_i]		//write i to the stack

test:	
	cmp	w21, size				//compare i to the size of the array
	b.lt 	loop_one			// if i<size, branch to loop_one

	add	w21, w21, 1				//increment i by 1
	str 	w21, [fp, index_i]		//write i to the stack

index_reset:
	
	mov 	w21, 1				//set i to 1
	str	w21, [fp, index_i]		//write i to the stack
	
		
loop_two:
	ldr 	w21, [fp, index_i]		//read i from the stack
	ldr 	w24, [arraybase, w21, sxtw 2]		//temp = a[i]
	str 	w24, [fp, temp_s]               //write temp to the stack 

	ldr 	w21, [fp, index_i]		//read i from the stack  
	mov 	w20, w21				//set the value of j to i
	str 	w20, [fp, index_j]		//write j to the stack 

	b	nested_test			//branch to the nested loop branch
	
nested_for:					//inner loop 
	ldr 	w22, [arraybase, w25, sxtw 2]         //read the number at A[j-1]
	str 	w22, [arraybase, w20, sxtw 2]	        //swap values of A[j] and A[j-1]

	ldr	w20, [fp, index_j]		//read j from the stack
	sub 	w20, w20, 1				//decrement by one
	str 	w20, [fp, index_j]		//write j to the stack 

		
nested_test:
	ldr	w20, [fp, index_j]		//read j from the stack
	cmp 	w20, 0				//compare j to 0 
	b.le	loop_sort			//if j<=0 branch to loop_sort
	
	ldr	w24, [fp, temp_s]		//read temp from the stack
	sub 	w25, w20, 1			//calculate j-1 for insert sorting
	ldr 	w22, [arraybase, w25, sxtw 2]         //read number at A[j-1]
	cmp 	w24, w22 		        //compare temp to array_num
	b.lt	nested_for			//if the temp < A[j-1] continue nested forloop


loop_sort:					//part of outer loop 
	ldr 	w20, [fp, index_j]		//read j from stack
	ldr 	w24, [fp, temp_s]		//read temp from stack
	str 	w24, [arraybase, w20, sxtw 2]		//store temp into the array at A[j]
	ldr	w21, [fp, index_i]		//read i from the stack
	add 	w21, w21, 1				//increment i by 1 
	str	w21, [fp, index_i]		//write i to the stack
	
test_two:					//outer loop 
	cmp 	w21, size				//compare i to size
	b.lt 	loop_two			//if i<size, iterate through outer loop again 

	
	mov 	w21, 0				//set i = 0 
	str	w21, [fp, index_i]		//write i to the stack
	
print_two:
	adrp	x0, sorted_array		//set x0 pointer to address to sorted_array string 
	add	w0, w0, :lo12:sorted_array	//put contents of string1 in x0
	mov 	w1, 0				//set arg 2 to 0 
	bl 	printf				//print sorted_array string

	
loop_three:
	ldr	w22,[arraybase, w21, sxtw 2]	        //read the number at A[i]
	adrp 	x0, array			//x0 pointer to addr. to string array
	add 	w0, w0, :lo12: array		//put contents of array string in x0 
	mov 	w1, w21				//set arg1 to i
	mov 	w2, w22			        //set arg2 to the array_num
	bl 	printf				//printf
	add 	w21, w21, 1				//increment i by 1 
	
test_three:	
	cmp 	w21, size				//compare i to the size
	b.lt 	loop_three			//i<size
end:
	mov 	w0, 0				//setup 0 return code
	ldp	fp, lr, [sp], dealloc		//-alloc
	ret
	

	
	

	
	
