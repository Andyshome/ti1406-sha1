#work of Zhiqiang Lei/Ziang Qiu

.global sha1_chunk

sha1_chunk:
  pushq   %rbp              #set up the base point
  movq    %rsp,     %rbp    #set up the current base point to here




  #save callers
  #because these registers are callee saved , so we need to push them.
  pushq   %rbx #push register rbx
  pushq   %r12 # push register r12
  pushq   %r13 # push register r13
  pushq   %r14
  pushq   %r15

  #start step one, Extend the sixteen 32-bit words into eighty 32-bit words:
  movq    $16,     %rbx # initialize the index , from 16 -> 80
extend_80_loop:
  # for i from 16 to 79
  #      w[i] := (w[i-3] xor w[i-8] xor w[i-14] xor w[i-16]) leftrotate 1
  movq    %rbx,    %r12 # use r12 to temp store the number
  subq    $3,      %r12 # calculate i - 3
  movl    (%rsi,%r12,4),  %r13d # move the w[i-3] value to r13d register, becasue it's 32 bit word.
  subq    $5,      %r12 # calculate i -5
  movl    (%rsi,%r12,4),  %r14d # movl w[i-8] in to register

  xor     %r14d,          %r13d # calculate the value

  subq    $6,             %r12 #  calculate i - 14
  movl    (%rsi,%r12,4),  %r14d # w[i-14]

  xor     %r14d,          %r13d # calculate xor
  subq    $2,             %r12 # i - 16
  movl    (%rsi,%r12,4),  %r14d # w[i-16]
  xor     %r14d,          %r13d # calculate xor
  rol     $1,            %r13d # leftretate 1
  movl    %r13d,         (%rsi,%rbx,4) # save the data

  addq    $1,            %rbx # change index

  cmpq    $79,           %rbx # end of the loop if more than 789

  jle     extend_80_loop

  movq    $0,            %rbx # save tge registers

  movq    %rdi,          %rdx # move the data address to rdx
  movl    (%rdx),        %r8d #a first address
  movl    4(%rdx),       %r9d #b
  movl    8(%rdx),       %r10d  #c
  movl    12(%rdx),      %r11d  #d
  movl    16(%rdx),      %r12d  #e
main_function:

  cmp     $19,             %rbx # compare the 19 to make calculation for 20 times
  jg      second_loop_20_39 # jmp if it's more than 20

first_loop_0_19:

#f := (b and c) or ((not b) and d)
#k := 0x5A827999
  movl    %r9d,            %r13d #b  - >  f
  and     %r10d,           %r13d #b and c
  movl    %r9d,            %r14d
  not     %r14d
  and     %r11d,           %r14d # ((not b) and d)
  or      %r14d,           %r13d
  movl    $0x5A827999,     %r15d
  jmp     end_of_main_loop


#  f := b xor c xor d
#  k := 0x6ED9EBA1
second_loop_20_39:
  cmp     $39,             %rbx
  jg      third_loop_40_59
  movl   %r9d,             %r13d # b ----> f
  xor    %r10d,            %r13d
  xor    %r11d,            %r13d
  movl   $0x6ED9EBA1,      %r15d
  jmp    end_of_main_loop


# f := (b and c) or (b and d) or(c and d)
# k := 0x8F1BBCDC
third_loop_40_59:
  cmp    $59,             %rbx
  jg      fourth_loop_60_79
  movl  %r9d,              %r13d
  and   %r10d,             %r13d
  movl  %r9d,              %r14d
  and   %r11d,             %r14d
  movl  %r10d,             %r15d
  and   %r11d,             %r15d
  or    %r14d,             %r13d
  or    %r15d,             %r13d
  movl  $0x8F1BBCDC,       %r15d
  jmp    end_of_main_loop

# f := b xor c xor d
# k := 0xCA62C1D6

fourth_loop_60_79:
  movl  %r9d,              %r13d
  xor   %r10d,             %r13d
  xor   %r11d,             %r13d
  movl  $0xCA62C1D6,       %r15d
  jmp    end_of_main_loop

# temp := (a leftrotate 5) + f + e + k + w[i]
#        e := d
#        d := c
#        c := b leftrotate 30
#        b := a
#        a := temp


end_of_main_loop:
  #set up rax is temp registers
  movl    %r8d,            %eax
  rol     $5,              %eax
  movl    (%rsi,%rbx,4),   %edx
  addl    %r13d,           %eax #f
  addl    %r12d,           %eax #e
  addl    %r15d,           %eax #k
  addl    %edx,            %eax #w[i]

  movl    %r11d,           %r12d # e := d
  movl    %r10d,           %r11d # d := c
  movl    %r9d,            %edx # tmp store the b value
  rol     $30,             %edx
  movl    %edx,            %r10d
  movl    %r8d,            %r9d
  movl    %eax,            %r8d
  addq    $1,              %rbx
  cmp     $79,             %rbx

  jle     main_function
#save the value
  add     %r8d,            (%rdi)
  add     %r9d,            4(%rdi)
  add     %r10d,           8(%rdi)
  add     %r11d,           12(%rdi)
  add     %r12d,           16(%rdi)
#clean the stack
  popq    %r15
  popq    %r14
  popq    %r13
  popq    %r12
  popq    %rbx
  movq    %rbp,            %rsp
  popq    %rbp
	ret
