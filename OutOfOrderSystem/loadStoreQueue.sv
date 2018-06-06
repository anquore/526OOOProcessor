//full means queue is full
//flush means a load beat a store with its value, flush system
//PCout is the PC of the head of the queue (the reversion point if flush is active)
//loadOrStore is 1 bit (1 load 0 store) for new issuing instructions
//ROBin is the 5 bit ROBid for new issuing instructions
//ifNew is high if a new load/store is to be issued in queue
//addrWrite is the 64 bit address of a load/store
//addrWriteROB is the 5 bit rob tag of the load/store to have addressed added
//ifAddrWrite is high when add address
//valWrite is the load/store value, written at some time as addr
//LSretire is when to retire the head of the list, check for conflicts, and shift list up one

module loadStoreQueue(full, flush, PCout, loadOrStore, PCin, ROBin, ifNew, addrWrite, addrWriteROB, ifAddrWrite, valWrite, LSretire, forwards, valOut, reset, needToRestore_i, clk);
	output logic full, flush, forwards;
	output logic [63:0] PCout, valOut;
	input logic loadOrStore, ifNew, ifAddrWrite;
	input logic [63:0] PCin, addrWrite, valWrite;
	input logic [4:0] ROBin, addrWriteROB;
	input logic LSretire, reset, needToRestore_i, clk;
	
	logic [200:0] so0, so1, so2, so3, so4, so5, so6, so7, so8, so9, so10, so11, so12, so13, so14, so15;
	logic LS0, LS1, LS2, LS3, LS4, LS5, LS6, LS7, LS8, LS9, LS10, LS11, LS12, LS13, LS14, LS15;
	logic vpc0, vpc1, vpc2, vpc3, vpc4, vpc5, vpc6, vpc7, vpc8, vpc9, vpc10, vpc11, vpc12, vpc13, vpc14, vpc15;
	logic [63:0] pc0, pc1, pc2, pc3, pc4, pc5, pc6, pc7, pc8, pc9, pc10, pc11, pc12, pc13, pc14, pc15;
	logic vaddr0, vaddr1, vaddr2, vaddr3, vaddr4, vaddr5, vaddr6, vaddr7, vaddr8, vaddr9, vaddr10, vaddr11, vaddr12, vaddr13, vaddr14, vaddr15;
	logic [63:0] addr0, addr1, addr2, addr3, addr4, addr5, addr6, addr7, addr8, addr9, addr10, addr11, addr12, addr13, addr14, addr15;
	logic vVal0, vVal1, vVal2, vVal3, vVal4, vVal5, vVal6, vVal7, vVal8, vVal9, vVal10, vVal11, vVal12, vVal13, vVal14, vVal15;
	logic [63:0] val0, val1, val2, val3, val4, val5, val6, val7, val8, val9, val10, val11, val12, val13, val14, val15;
	logic [4:0] rob0, rob1, rob2, rob3, rob4, rob5, rob6, rob7, rob8, rob9, rob10, rob11, rob12, rob13, rob14, rob15;
	//enable control
	logic enNew0, enNew1, enNew2, enNew3, enNew4, enNew5, enNew6, enNew7, enNew8, enNew9, enNew10, enNew11, enNew12, enNew13, enNew14, enNew15;
	logic enAddr0, enAddr1, enAddr2, enAddr3, enAddr4, enAddr5, enAddr6, enAddr7, enAddr8, enAddr9, enAddr10, enAddr11, enAddr12, enAddr13, enAddr14, enAddr15;
	logic enVal0, enVal1, enVal2, enVal3, enVal4, enVal5, enVal6, enVal7, enVal8, enVal9, enVal10, enVal11, enVal12, enVal13, enVal14, enVal15;
	logic [15:0] jVal;
	logic naddr0, naddr1, naddr2, naddr3, naddr4, naddr5, naddr6, naddr7, naddr8, naddr9, naddr10, naddr11, naddr12, naddr13, naddr14, naddr15;
	logic maddr0, maddr1, maddr2, maddr3, maddr4, maddr5, maddr6, maddr7, maddr8, maddr9, maddr10, maddr11, maddr12, maddr13, maddr14, maddr15;
	logic [3:0] tailAddr;
	//reg structure: LoadStore (load 1, store 0)[200], valid_PC[199], PC (64 bit)[198:135], ROBid (5 bit) [134:130], valid_addr[129], addr (64 bit)[128:65], valid_val[64], val (64 bit)[63:0]
	loadStoreRegister reg0(.out(so0), .newIn({LS0, vpc0, pc0, rob0}), .enNew(enNew0), .addrIn({vaddr0, addr0}), .enAddr(enAddr0), .valIn({vVal0, val0}), .enVal(enVal0), .reset, .clk);
	loadStoreRegister reg1(.out(so1), .newIn({LS1, vpc1, pc1, rob1}), .enNew(enNew1), .addrIn({vaddr1, addr1}), .enAddr(enAddr1), .valIn({vVal1, val1}), .enVal(enVal1), .reset, .clk);
	loadStoreRegister reg2(.out(so2), .newIn({LS2, vpc2, pc2, rob2}), .enNew(enNew2), .addrIn({vaddr2, addr2}), .enAddr(enAddr2), .valIn({vVal2, val2}), .enVal(enVal2), .reset, .clk);
	loadStoreRegister reg3(.out(so3), .newIn({LS3, vpc3, pc3, rob3}), .enNew(enNew3), .addrIn({vaddr3, addr3}), .enAddr(enAddr3), .valIn({vVal3, val3}), .enVal(enVal3), .reset, .clk);
	loadStoreRegister reg4(.out(so4), .newIn({LS4, vpc4, pc4, rob4}), .enNew(enNew4), .addrIn({vaddr4, addr4}), .enAddr(enAddr4), .valIn({vVal4, val4}), .enVal(enVal4), .reset, .clk);
	loadStoreRegister reg5(.out(so5), .newIn({LS5, vpc5, pc5, rob5}), .enNew(enNew5), .addrIn({vaddr5, addr5}), .enAddr(enAddr5), .valIn({vVal5, val5}), .enVal(enVal5), .reset, .clk);
	loadStoreRegister reg6(.out(so6), .newIn({LS6, vpc6, pc6, rob6}), .enNew(enNew6), .addrIn({vaddr6, addr6}), .enAddr(enAddr6), .valIn({vVal6, val6}), .enVal(enVal6), .reset, .clk);
	loadStoreRegister reg7(.out(so7), .newIn({LS7, vpc7, pc7, rob7}), .enNew(enNew7), .addrIn({vaddr7, addr7}), .enAddr(enAddr7), .valIn({vVal7, val7}), .enVal(enVal7), .reset, .clk);
	loadStoreRegister reg8(.out(so8), .newIn({LS8, vpc8, pc8, rob8}), .enNew(enNew8), .addrIn({vaddr8, addr8}), .enAddr(enAddr8), .valIn({vVal8, val8}), .enVal(enVal8), .reset, .clk);
	loadStoreRegister reg9(.out(so9), .newIn({LS9, vpc9, pc9, rob9}), .enNew(enNew9), .addrIn({vaddr9, addr9}), .enAddr(enAddr9), .valIn({vVal9, val9}), .enVal(enVal9), .reset, .clk);
	loadStoreRegister reg10(.out(so10), .newIn({LS10, vpc10, pc10, rob10}), .enNew(enNew10), .addrIn({vaddr10, addr10}), .enAddr(enAddr10), .valIn({vVal10, val10}), .enVal(enVal10), .reset, .clk);
	loadStoreRegister reg11(.out(so11), .newIn({LS11, vpc11, pc11, rob11}), .enNew(enNew11), .addrIn({vaddr11, addr11}), .enAddr(enAddr11), .valIn({vVal11, val11}), .enVal(enVal11), .reset, .clk);
	loadStoreRegister reg12(.out(so12), .newIn({LS12, vpc12, pc12, rob12}), .enNew(enNew12), .addrIn({vaddr12, addr12}), .enAddr(enAddr12), .valIn({vVal12, val12}), .enVal(enVal12), .reset, .clk);
	loadStoreRegister reg13(.out(so13), .newIn({LS13, vpc13, pc13, rob13}), .enNew(enNew13), .addrIn({vaddr13, addr13}), .enAddr(enAddr13), .valIn({vVal13, val13}), .enVal(enVal13), .reset, .clk);
	loadStoreRegister reg14(.out(so14), .newIn({LS14, vpc14, pc14, rob14}), .enNew(enNew14), .addrIn({vaddr14, addr14}), .enAddr(enAddr14), .valIn({vVal14, val14}), .enVal(enVal14), .reset, .clk);
	loadStoreRegister reg15(.out(so15), .newIn({LS15, vpc15, pc15, rob15}), .enNew(enNew15), .addrIn({vaddr15, addr15}), .enAddr(enAddr15), .valIn({vVal15, val15}), .enVal(enVal15), .reset, .clk);
	logic [5:0] rso0, rso1, rso2, rso3, rso4, rso5, rso6, rso7, rso8, rso9, rso10, rso11, rso12, rso13, rso14, rso15;
	logic [5:0] rsi0, rsi1, rsi2, rsi3, rsi4, rsi5, rsi6, rsi7, rsi8, rsi9, rsi10, rsi11, rsi12, rsi13, rsi14, rsi15;
	wallOfDFFsX6 forReg0(.q(rso0), .d(rsi0), .reset, .enable(enAddr0), .clk);
	wallOfDFFsX6 forReg1(.q(rso1), .d(rsi1), .reset, .enable(enAddr1), .clk);
	wallOfDFFsX6 forReg2(.q(rso2), .d(rsi2), .reset, .enable(enAddr2), .clk);
	wallOfDFFsX6 forReg3(.q(rso3), .d(rsi3), .reset, .enable(enAddr3), .clk);
	wallOfDFFsX6 forReg4(.q(rso4), .d(rsi4), .reset, .enable(enAddr4), .clk);
	wallOfDFFsX6 forReg5(.q(rso5), .d(rsi5), .reset, .enable(enAddr5), .clk);
	wallOfDFFsX6 forReg6(.q(rso6), .d(rsi6), .reset, .enable(enAddr6), .clk);
	wallOfDFFsX6 forReg7(.q(rso7), .d(rsi7), .reset, .enable(enAddr7), .clk);
	wallOfDFFsX6 forReg8(.q(rso8), .d(rsi8), .reset, .enable(enAddr8), .clk);
	wallOfDFFsX6 forReg9(.q(rso9), .d(rsi9), .reset, .enable(enAddr9), .clk);
	wallOfDFFsX6 forReg10(.q(rso10), .d(rsi10), .reset, .enable(enAddr10), .clk);
	wallOfDFFsX6 forReg11(.q(rso11), .d(rsi11), .reset, .enable(enAddr11), .clk);
	wallOfDFFsX6 forReg12(.q(rso12), .d(rsi12), .reset, .enable(enAddr12), .clk);
	wallOfDFFsX6 forReg13(.q(rso13), .d(rsi13), .reset, .enable(enAddr13), .clk);
	wallOfDFFsX6 forReg14(.q(rso14), .d(rsi14), .reset, .enable(enAddr14), .clk);
	wallOfDFFsX6 forReg15(.q(rso15), .d(rsi15), .reset, .enable(enAddr15), .clk);
	
	//retirment checker
	logic adcmpIn, adcmp1, adcmp2, adcmp3, adcmp4, adcmp5, adcmp6, adcmp7, adcmp8, adcmp9, adcmp10, adcmp11, adcmp12, adcmp13, adcmp14, adcmp15;
	logic adcmprob1, adcmprob2, adcmprob3, adcmprob4, adcmprob5, adcmprob6, adcmprob7, adcmprob8, adcmprob9, adcmprob10, adcmprob11, adcmprob12, adcmprob13, adcmprob14, adcmprob15;
	logic isLoadIncoming;
	always_comb begin
		adcmp1 = (~|(so0[128:65]^so1[128:65]))&so1[200]&so1[129];		adcmp2 = (~|(so0[128:65]^so2[128:65]))&so2[200]&so2[129];
		adcmp3 = (~|(so0[128:65]^so3[128:65]))&so3[200]&so3[129];		adcmp4 = (~|(so0[128:65]^so4[128:65]))&so4[200]&so4[129];
		adcmp5 = (~|(so0[128:65]^so5[128:65]))&so5[200]&so5[129];		adcmp6 = (~|(so0[128:65]^so6[128:65]))&so6[200]&so6[129];
		adcmp7 = (~|(so0[128:65]^so7[128:65]))&so7[200]&so7[129];		adcmp8 = (~|(so0[128:65]^so8[128:65]))&so8[200]&so8[129];
		adcmp9 = (~|(so0[128:65]^so9[128:65]))&so9[200]&so9[129];		adcmp10 = (~|(so0[128:65]^so10[128:65]))&so10[200]&so10[129];
		adcmp11 = (~|(so0[128:65]^so11[128:65]))&so11[200]&so11[129];		adcmp12 = (~|(so0[128:65]^so12[128:65]))&so12[200]&so12[129];
		adcmp13 = (~|(so0[128:65]^so13[128:65]))&so13[200]&so13[129];		adcmp14 = (~|(so0[128:65]^so14[128:65]))&so14[200]&so14[129];
		adcmp15 = (~|(so0[128:65]^so15[128:65]))&so15[200]&so15[129];		adcmpIn = (~|(so0[128:65]^addrWrite))&isLoadIncoming;
		
		adcmprob1 = (~|(so0[134:130]^rso1[4:0]))&rso1[5];			adcmprob2 = (~|(so0[134:130]^rso2[4:0]))&rso2[5];
		adcmprob3 = (~|(so0[134:130]^rso3[4:0]))&rso3[5];			adcmprob4 = (~|(so0[134:130]^rso4[4:0]))&rso4[5];
		adcmprob5 = (~|(so0[134:130]^rso5[4:0]))&rso5[5];			adcmprob6 = (~|(so0[134:130]^rso6[4:0]))&rso6[5];
		adcmprob7 = (~|(so0[134:130]^rso7[4:0]))&rso7[5];			adcmprob8 = (~|(so0[134:130]^rso8[4:0]))&rso8[5];
		adcmprob9 = (~|(so0[134:130]^rso9[4:0]))&rso9[5];			adcmprob10 = (~|(so0[134:130]^rso10[4:0]))&rso10[5];
		adcmprob11 = (~|(so0[134:130]^rso11[4:0]))&rso11[5];			adcmprob12 = (~|(so0[134:130]^rso12[4:0]))&rso12[5];
		adcmprob13 = (~|(so0[134:130]^rso13[4:0]))&rso13[5];			adcmprob14 = (~|(so0[134:130]^rso14[4:0]))&rso14[5];
		adcmprob15 = (~|(so0[134:130]^rso15[4:0]))&rso15[5];
	end
	assign flush = ((adcmpIn&~forwards)|(adcmp1&~adcmprob1)|(adcmp2&~adcmprob2)|(adcmp3&~adcmprob3)|(adcmp4&~adcmprob4)|(adcmp5&~adcmprob5)|(adcmp6&~adcmprob6)|(adcmp7&~adcmprob7)|
		(adcmp8&~adcmprob8)|(adcmp9&~adcmprob9)|(adcmp10&~adcmprob10)|(adcmp11&~adcmprob11)|(adcmp12&~adcmprob12)|(adcmp13&~adcmprob13)|(adcmp14&~adcmprob14)|(adcmp15&~adcmprob15))&~so0[200];
	
	//forwarding unit
	logic adValcmp0, adValcmp1, adValcmp2, adValcmp3, adValcmp4, adValcmp5, adValcmp6, adValcmp7, adValcmp8, adValcmp9, adValcmp10, adValcmp11, adValcmp12, adValcmp13, adValcmp14;
	logic fm0, fm1, fm2, fm3, fm4, fm5, fm6, fm7, fm8, fm9, fm10, fm11, fm12, fm13, fm14, fm15;
	logic pfm0, pfm1, pfm2, pfm3, pfm4, pfm5, pfm6, pfm7, pfm8, pfm9, pfm10, pfm11, pfm12, pfm13, pfm14, pfm15;
	always_comb begin
		adValcmp0 = ~(|(addrWrite^so0[128:65])|so0[200])&so0[129];			adValcmp1 = ~(|(addrWrite^so1[128:65])|so1[200])&so1[129];
		adValcmp2 = ~(|(addrWrite^so2[128:65])|so2[200])&so2[129];			adValcmp3 = ~(|(addrWrite^so3[128:65])|so3[200])&so3[129];
		adValcmp4 = ~(|(addrWrite^so4[128:65])|so4[200])&so4[129];			adValcmp5 = ~(|(addrWrite^so5[128:65])|so5[200])&so5[129];
		adValcmp6 = ~(|(addrWrite^so6[128:65])|so6[200])&so6[129];			adValcmp7 = ~(|(addrWrite^so7[128:65])|so7[200])&so7[129];
		adValcmp8 = ~(|(addrWrite^so8[128:65])|so8[200])&so8[129];			adValcmp9 = ~(|(addrWrite^so9[128:65])|so9[200])&so9[129];
		adValcmp10 = ~(|(addrWrite^so10[128:65])|so10[200])&so10[129];		adValcmp11 = ~(|(addrWrite^so11[128:65])|so11[200])&so11[129];
		adValcmp12 = ~(|(addrWrite^so12[128:65])|so12[200])&so12[129];		adValcmp13 = ~(|(addrWrite^so13[128:65])|so13[200])&so13[129];
		adValcmp14 = ~(|(addrWrite^so14[128:65])|so14[200])&so14[129];
		
		fm0 = (~|(addrWrite^so0[128:65]))&so0[129];	fm1 = (~|(addrWrite^so1[128:65]))&so1[129];	fm2 = (~|(addrWrite^so2[128:65]))&so2[129];	fm3 = (~|(addrWrite^so3[128:65]))&so3[129];
		fm4 = (~|(addrWrite^so4[128:65]))&so4[129];	fm5 = (~|(addrWrite^so5[128:65]))&so5[129];	fm6 = (~|(addrWrite^so6[128:65]))&so6[129];	fm7 = (~|(addrWrite^so7[128:65]))&so7[129];
		fm8 = (~|(addrWrite^so8[128:65]))&so8[129];	fm9 = (~|(addrWrite^so9[128:65]))&so9[129];	fm10 = (~|(addrWrite^so10[128:65]))&so10[129];	fm11 = (~|(addrWrite^so11[128:65]))&so11[129];
		fm12 = (~|(addrWrite^so12[128:65]))&so12[129];	fm13 = (~|(addrWrite^so13[128:65]))&so13[129];	fm14 = (~|(addrWrite^so14[128:65]))&so14[129];	fm15 = (~|(addrWrite^so15[128:65]))&so15[129];
		pfm15=fm15;		pfm14=fm14&~pfm15;	pfm13=fm13&~pfm14;	pfm12=fm12&~pfm13;	pfm11=fm11&~pfm12;	pfm10=fm10&~pfm11;
		pfm9=fm9&~pfm10;	pfm8=fm8&~pfm9;		pfm7=fm7&~pfm8;		pfm6=fm6&~pfm7;		pfm5=fm5&~pfm6;		pfm4=fm4&~pfm5;
		pfm3=fm3&~pfm4;		pfm2=fm2&~pfm3;		pfm1=fm1&~pfm2;		pfm0=fm0&~pfm1;//added ~ back in
	end
	logic aXor0, aXor1, aXor2, aXor3, aXor4, aXor5, aXor6, aXor7, aXor8, aXor9, aXor10, aXor11, aXor12, aXor13, aXor14, aXor15;
	assign isLoadIncoming = (aXor14&so14[200])|(aXor13&so13[200])|(aXor12&so12[200])|(aXor11&so11[200])|(aXor10&so10[200])|(aXor9&so9[200])|(aXor8&so8[200])|
		(aXor7&so7[200])|(aXor6&so6[200])|(aXor5&so5[200])|(aXor4&so4[200])|(aXor3&so3[200])|(aXor2&so2[200])|(aXor1&so1[200])|(aXor0&so0[200]);
	assign forwards = ifAddrWrite&isLoadIncoming&(adValcmp0|adValcmp1|adValcmp2|adValcmp3|adValcmp4|adValcmp5|adValcmp6|adValcmp7
		|adValcmp8|adValcmp9|adValcmp10|adValcmp11|adValcmp12|adValcmp13|adValcmp14);
	logic [3:0] forwardAddr;
	assign forwardAddr[0]=(pfm1|pfm3|pfm5|pfm7|pfm9|pfm11|pfm13|pfm15);	assign forwardAddr[1]=(pfm2|pfm3|pfm6|pfm7|pfm10|pfm11|pfm14|pfm15);
	assign forwardAddr[2]=(pfm4|pfm5|pfm6|pfm7|pfm12|pfm13|pfm14|pfm15);	assign forwardAddr[3]=(pfm8|pfm9|pfm10|pfm11|pfm12|pfm13|pfm14|pfm15);
	mux16x1X64 forwardingMux(.outs(valOut[63:0]), .addr(forwardAddr), .muxIns({so15[63:0], so14[63:0], so13[63:0], so12[63:0], so11[63:0], so10[63:0], so9[63:0], so8[63:0],
		so7[63:0], so6[63:0], so5[63:0], so4[63:0], so3[63:0], so2[63:0], so1[63:0], so0[63:0]}));
	logic [4:0] robTagFor;
	assign robTagFor = (({5{pfm15}}&so15[134:130])|({5{pfm14}}&so14[134:130])|({5{pfm13}}&so13[134:130])|({5{pfm12}}&so12[134:130])|({5{pfm11}}&so11[134:130])|
		({5{pfm10}}&so10[134:130])|({5{pfm8}}&so8[134:130])|({5{pfm7}}&so7[134:130])|({5{pfm6}}&so6[134:130])|({5{pfm5}}&so5[134:130])|({5{pfm4}}&so4[134:130])|
		({5{pfm3}}&so3[134:130])|({5{pfm2}}&so2[134:130])|({5{pfm1}}&so1[134:130])|({5{pfm0}}&so0[134:130]));
	//end of forwarding unit
	
	always_comb begin
		enNew0 = LSretire|(jVal[0]&ifNew);	enNew1 = LSretire|(jVal[1]&ifNew);	enNew2 = LSretire|(jVal[2]&ifNew);	enNew3 = LSretire|(jVal[3]&ifNew);
		enNew4 = LSretire|(jVal[4]&ifNew);	enNew5 = LSretire|(jVal[5]&ifNew);	enNew6 = LSretire|(jVal[6]&ifNew);	enNew7 = LSretire|(jVal[7]&ifNew);
		enNew8 = LSretire|(jVal[8]&ifNew);	enNew9 = LSretire|(jVal[9]&ifNew);	enNew10 = LSretire|(jVal[10]&ifNew);	enNew11 = LSretire|(jVal[11]&ifNew);
		enNew12 = LSretire|(jVal[12]&ifNew);	enNew13 = LSretire|(jVal[13]&ifNew);	enNew14 = LSretire|(jVal[14]&ifNew);	enNew15 = LSretire|(jVal[15]&ifNew);
		
		enAddr0 = LSretire|(maddr0&ifAddrWrite);	enAddr1 = LSretire|(maddr1&ifAddrWrite);	enAddr2 = LSretire|(maddr2&ifAddrWrite);	enAddr3 = LSretire|(maddr3&ifAddrWrite);
		enAddr4 = LSretire|(maddr4&ifAddrWrite);	enAddr5 = LSretire|(maddr5&ifAddrWrite);	enAddr6 = LSretire|(maddr6&ifAddrWrite);	enAddr7 = LSretire|(maddr7&ifAddrWrite);
		enAddr8 = LSretire|(maddr8&ifAddrWrite);	enAddr9 = LSretire|(maddr9&ifAddrWrite);	enAddr10 = LSretire|(maddr10&ifAddrWrite);	enAddr11 = LSretire|(maddr11&ifAddrWrite);
		enAddr12 = LSretire|(maddr12&ifAddrWrite);	enAddr13 = LSretire|(maddr13&ifAddrWrite);	enAddr14 = LSretire|(maddr14&ifAddrWrite);	enAddr15 = LSretire|(maddr15&ifAddrWrite);
		
		enVal0 = enAddr0;			enVal1 = enAddr1;			enVal2 = enAddr2;			enVal3 = enAddr3;
		enVal4 = enAddr4;			enVal5 = enAddr5;			enVal6 = enAddr6;			enVal7 = enAddr7;
		enVal8 = enAddr8;			enVal9 = enAddr9;			enVal10 = enAddr10;			enVal11 = enAddr11;
		enVal12 = enAddr12;			enVal13 = enAddr13;			enVal14 = enAddr14;			enVal15 = enAddr15;
	end
	
	//shift muxes
	assign jVal[15] = (tailAddr==4'hF);	assign jVal[14] = (tailAddr==4'hE);	assign jVal[13] = (tailAddr==4'hD);	assign jVal[12] = (tailAddr==4'hC);
	assign jVal[11] = (tailAddr==4'hB);	assign jVal[10] = (tailAddr==4'hA);	assign jVal[9] = (tailAddr==4'h9);	assign jVal[8] = (tailAddr==4'h8);
	assign jVal[7] = (tailAddr==4'h7);	assign jVal[6] = (tailAddr==4'h6);	assign jVal[5] = (tailAddr==4'h5);	assign jVal[4] = (tailAddr==4'h4);
	assign jVal[3] = (tailAddr==4'h3);	assign jVal[2] = (tailAddr==4'h2);	assign jVal[1] = (tailAddr==4'h1);	assign jVal[0] = (tailAddr==4'h0);
	//logic mLS0, mLS1, mLS2, mLS3, mLS4, mLS5, mLS6, mLS7, mLS8, mLS9, mLS10, mLS11, mLS12, mLS13, mLS14;
	//logic mvaddr0, mvaddr1, mvaddr2, mvaddr3, mvaddr4, mvaddr5, mvaddr6, mvaddr7, mvaddr8, mvaddr9, mvaddr10, mvaddr11, mvaddr12, mvaddr13, mvaddr14, mvaddr15;
	
	
	always_comb begin
		
		naddr0=ifNew&((jVal[0]&~LSretire)|(jVal[1]&LSretire));	naddr1=ifNew&((jVal[1]&~LSretire)|(jVal[2]&LSretire));	naddr2=ifNew&((jVal[2]&~LSretire)|(jVal[3]&LSretire));	naddr3=ifNew&((jVal[3]&~LSretire)|(jVal[4]&LSretire));
		naddr4=ifNew&((jVal[4]&~LSretire)|(jVal[5]&LSretire));	naddr5=ifNew&((jVal[5]&~LSretire)|(jVal[6]&LSretire));	naddr6=ifNew&((jVal[6]&~LSretire)|(jVal[7]&LSretire));	naddr7=ifNew&((jVal[7]&~LSretire)|(jVal[8]&LSretire));
		naddr8=ifNew&((jVal[8]&~LSretire)|(jVal[9]&LSretire));	naddr9=ifNew&((jVal[9]&~LSretire)|(jVal[10]&LSretire));	naddr10=ifNew&((jVal[10]&~LSretire)|(jVal[11]&LSretire));	naddr11=ifNew&((jVal[11]&~LSretire)|(jVal[12]&LSretire));
		naddr12=ifNew&((jVal[12]&~LSretire)|(jVal[13]&LSretire));	naddr13=ifNew&((jVal[13]&~LSretire)|(jVal[14]&LSretire));	naddr14=ifNew&((jVal[14]&~LSretire)|(jVal[15]&LSretire));	naddr15=ifNew&(jVal[15]&~LSretire);
		
		if(naddr0) begin LS0=loadOrStore;	pc0=PCin;		rob0=ROBin; end else begin LS0=so1[200];		pc0=so1[198:135];	rob0=so1[134:130]; end
		if(naddr1) begin LS1=loadOrStore;	pc1=PCin;		rob1=ROBin; end else begin LS1=so2[200];		pc1=so2[198:135];	rob1=so2[134:130]; end
		if(naddr2) begin LS2=loadOrStore;	pc2=PCin;		rob2=ROBin; end else begin LS2=so3[200];		pc2=so3[198:135];	rob2=so3[134:130]; end
		if(naddr3) begin LS3=loadOrStore;	pc3=PCin;		rob3=ROBin; end else begin LS3=so4[200];		pc3=so4[198:135];	rob3=so4[134:130]; end
		if(naddr4) begin LS4=loadOrStore;	pc4=PCin;		rob4=ROBin; end else begin LS4=so5[200];		pc4=so5[198:135];	rob4=so5[134:130]; end
		if(naddr5) begin LS5=loadOrStore;	pc5=PCin;		rob5=ROBin; end else begin LS5=so6[200];		pc5=so6[198:135];	rob5=so6[134:130]; end
		if(naddr6) begin LS6=loadOrStore;	pc6=PCin;		rob6=ROBin; end else begin LS6=so7[200];		pc6=so7[198:135];	rob6=so7[134:130]; end
		if(naddr7) begin LS7=loadOrStore;	pc7=PCin;		rob7=ROBin; end else begin LS7=so8[200];		pc7=so8[198:135];	rob7=so8[134:130]; end	
		if(naddr8) begin LS8=loadOrStore;	pc8=PCin;		rob8=ROBin; end else begin LS8=so9[200];		pc8=so9[198:135];	rob8=so9[134:130]; end
		if(naddr9) begin LS9=loadOrStore;	pc9=PCin;		rob9=ROBin; end else begin LS9=so10[200];		pc9=so10[198:135];	rob9=so10[134:130]; end
		if(naddr10) begin LS10=loadOrStore;	pc10=PCin;		rob10=ROBin; end else begin LS10=so11[200];		pc10=so11[198:135];	rob10=so11[134:130]; end
		if(naddr11) begin LS11=loadOrStore;	pc11=PCin;		rob11=ROBin; end else begin LS11=so12[200];		pc11=so12[198:135];	rob11=so12[134:130]; end
		if(naddr12) begin LS12=loadOrStore;	pc12=PCin;		rob12=ROBin; end else begin LS12=so13[200];		pc12=so13[198:135];	rob12=so13[134:130]; end
		if(naddr13) begin LS13=loadOrStore;	pc13=PCin;		rob13=ROBin; end else begin LS13=so14[200];		pc13=so14[198:135];	rob13=so14[134:130]; end
		if(naddr14) begin LS14=loadOrStore;	pc14=PCin;		rob14=ROBin; end else begin LS14=so15[200];		pc14=so15[198:135];	rob14=so15[134:130]; end
		if(naddr15) begin LS15=loadOrStore; pc15=PCin;		rob15=ROBin; end else begin LS15=1'b0;			pc15=64'h0;			rob15=5'h0; end
		
		if(maddr0) begin addr0=addrWrite;	val0=valWrite; rsi0[5:0]={forwards, robTagFor};		end else begin addr0=so1[128:65];	val0=so1[63:0]; rsi0[5:0]=rso1[5:0]; end
		if(maddr1) begin addr1=addrWrite;	val1=valWrite; rsi1[5:0]={forwards, robTagFor};		end else begin addr1=so2[128:65];	val1=so2[63:0]; rsi1[5:0]=rso2[5:0]; end
		if(maddr2) begin addr2=addrWrite;	val2=valWrite; rsi2[5:0]={forwards, robTagFor};		end else begin addr2=so3[128:65];	val2=so3[63:0]; rsi2[5:0]=rso3[5:0]; end
		if(maddr3) begin addr3=addrWrite;	val3=valWrite; rsi3[5:0]={forwards, robTagFor};		end else begin addr3=so4[128:65];	val3=so4[63:0]; rsi3[5:0]=rso4[5:0]; end
		if(maddr4) begin addr4=addrWrite;	val4=valWrite; rsi4[5:0]={forwards, robTagFor};		end else begin addr4=so5[128:65];	val4=so5[63:0]; rsi4[5:0]=rso5[5:0]; end
		if(maddr5) begin addr5=addrWrite;	val5=valWrite; rsi5[5:0]={forwards, robTagFor};		end else begin addr5=so6[128:65];	val5=so6[63:0]; rsi5[5:0]=rso6[5:0]; end
		if(maddr6) begin addr6=addrWrite;	val6=valWrite; rsi6[5:0]={forwards, robTagFor};		end else begin addr6=so7[128:65];	val6=so7[63:0]; rsi6[5:0]=rso7[5:0]; end
		if(maddr7) begin addr7=addrWrite;	val7=valWrite; rsi7[5:0]={forwards, robTagFor};		end else begin addr7=so8[128:65];	val7=so8[63:0]; rsi7[5:0]=rso8[5:0]; end
		if(maddr8) begin addr8=addrWrite;	val8=valWrite; rsi8[5:0]={forwards, robTagFor};		end else begin addr8=so9[128:65];	val8=so9[63:0]; rsi8[5:0]=rso9[5:0]; end
		if(maddr9) begin addr9=addrWrite;	val9=valWrite; rsi9[5:0]={forwards, robTagFor};		end else begin addr9=so10[128:65];	val9=so10[63:0]; rsi9[5:0]=rso10[5:0]; end
		if(maddr10) begin addr10=addrWrite;	val10=valWrite; rsi10[5:0]={forwards, robTagFor};	end else begin addr10=so11[128:65];	val10=so11[63:0]; rsi10[5:0]=rso11[5:0]; end
		if(maddr11) begin addr11=addrWrite;	val11=valWrite; rsi11[5:0]={forwards, robTagFor};	end else begin addr11=so12[128:65];	val11=so12[63:0]; rsi11[5:0]=rso12[5:0]; end
		if(maddr12) begin addr12=addrWrite;	val12=valWrite; rsi12[5:0]={forwards, robTagFor};	end else begin addr12=so13[128:65];	val12=so13[63:0]; rsi12[5:0]=rso13[5:0]; end
		if(maddr13) begin addr13=addrWrite;	val13=valWrite; rsi13[5:0]={forwards, robTagFor};	end else begin addr13=so14[128:65];	val13=so14[63:0]; rsi13[5:0]=rso14[5:0]; end
		if(maddr14) begin addr14=addrWrite;	val14=valWrite; rsi14[5:0]={forwards, robTagFor};	end else begin addr14=so15[128:65];	val14=so15[63:0]; rsi14[5:0]=rso15[5:0]; end
		if(maddr15) begin addr15=addrWrite;	val15=valWrite;	rsi15[5:0]={forwards, robTagFor};	end else begin addr15=64'h0;		val15=64'h0;	rsi15[5:0]=6'h0; end
		
		LS15 = jVal[15]&loadOrStore;
		
		vpc0 = so1[199]|(naddr0&ifNew);	vpc1 = so2[199]|(naddr1&ifNew);	vpc2 = so3[199]|(naddr2&ifNew);	vpc3 = so4[199]|(naddr3&ifNew);
		vpc4 = so5[199]|(naddr4&ifNew);	vpc5 = so6[199]|(naddr5&ifNew);	vpc6 = so7[199]|(naddr6&ifNew);	vpc7 = so8[199]|(naddr7&ifNew);
		vpc8 = so9[199]|(naddr8&ifNew);	vpc9 = so10[199]|(naddr9&ifNew);	vpc10 = so11[199]|(naddr10&ifNew);	vpc11 = so12[199]|(naddr11&ifNew);
		vpc12 = so13[199]|(naddr12&ifNew);	vpc13 = so14[199]|(naddr13&ifNew);	vpc14 = so15[199]|(naddr14&ifNew);	vpc15 = naddr15&ifNew;
		
		pc15 = {64{naddr15}}&PCin;
		
		rob15 = {5{naddr15}}&ROBin;
		
		vaddr0 = so1[129]|maddr0;		vaddr1 = so2[129]|maddr1;		vaddr2 = so3[129]|maddr2;		vaddr3 = so4[129]|maddr3;
		vaddr4 = so5[129]|maddr4;		vaddr5 = so6[129]|maddr5;		vaddr6 = so7[129]|maddr6;		vaddr7 = so8[129]|maddr7;
		vaddr8 = so9[129]|maddr8;		vaddr9 = so10[129]|maddr9;		vaddr10 = so11[129]|maddr10;		vaddr11 = so12[129]|maddr11;
		vaddr12 = so13[129]|maddr12;		vaddr13 = so14[129]|maddr13;		vaddr14 = so15[129]|maddr14;		vaddr15 = maddr15;
		
		addr15 = {64{maddr15}}&addrWrite;
		
		vVal0 = 0;				vVal1 = 0;				vVal2 = 0;				vVal3 = 0;
		vVal4 = 0;				vVal5 = 0;				vVal6 = 0;				vVal7 = 0;
		vVal8 = 0;				vVal9 = 0;				vVal10 = 0;				vVal11 = 0;
		vVal12 = 0;				vVal13 = 0;				vVal14 = 0;				vVal15 = 0;
		
		val15 = addrWrite;
	end
	
	//mux control search ROB tags
	logic [15:0] lXor0, lXor1, lXor2, lXor3, lXor4, lXor5, lXor6, lXor7, lXor8, lXor9, lXor10, lXor11, lXor12, lXor13, lXor14, lXor15;
	always_comb begin
		aXor0 = ~|(addrWriteROB^so0[134:130]);	aXor1 = ~|(addrWriteROB^so1[134:130]);	aXor2 = ~|(addrWriteROB^so2[134:130]);	aXor3 = ~|(addrWriteROB^so3[134:130]);
		aXor4 = ~|(addrWriteROB^so4[134:130]);	aXor5 = ~|(addrWriteROB^so5[134:130]);	aXor6 = ~|(addrWriteROB^so6[134:130]);	aXor7 = ~|(addrWriteROB^so7[134:130]);
		aXor8 = ~|(addrWriteROB^so8[134:130]);	aXor9 = ~|(addrWriteROB^so9[134:130]);	aXor10 = ~|(addrWriteROB^so10[134:130]);aXor11 = ~|(addrWriteROB^so11[134:130]);
		aXor12 = ~|(addrWriteROB^so12[134:130]);aXor13 = ~|(addrWriteROB^so13[134:130]);aXor14 = ~|(addrWriteROB^so14[134:130]);aXor15 = ~|(addrWriteROB^so15[134:130]);
		maddr0 = ((aXor0&~LSretire)|(aXor1&LSretire))&ifAddrWrite;		maddr1 = ((aXor1&~LSretire)|(aXor2&LSretire))&ifAddrWrite;
		maddr2 = ((aXor2&~LSretire)|(aXor3&LSretire))&ifAddrWrite;		maddr3 = ((aXor3&~LSretire)|(aXor4&LSretire))&ifAddrWrite;
		maddr4 = ((aXor4&~LSretire)|(aXor5&LSretire))&ifAddrWrite;		maddr5 = ((aXor5&~LSretire)|(aXor6&LSretire))&ifAddrWrite;
		maddr6 = ((aXor6&~LSretire)|(aXor7&LSretire))&ifAddrWrite;		maddr7 = ((aXor7&~LSretire)|(aXor8&LSretire))&ifAddrWrite;
		maddr8 = ((aXor8&~LSretire)|(aXor9&LSretire))&ifAddrWrite;		maddr9 = ((aXor9&~LSretire)|(aXor10&LSretire))&ifAddrWrite;
		maddr10 = ((aXor10&~LSretire)|(aXor11&LSretire))&ifAddrWrite;		maddr11 = ((aXor11&~LSretire)|(aXor12&LSretire))&ifAddrWrite;
		maddr12 = ((aXor12&~LSretire)|(aXor13&LSretire))&ifAddrWrite;		maddr13 = ((aXor13&~LSretire)|(aXor14&LSretire))&ifAddrWrite;
		maddr14 = ((aXor14&~LSretire)|(aXor15&LSretire))&ifAddrWrite;		maddr15 = (aXor15&~LSretire)&ifAddrWrite;
	end
	
	//counter for tail
	always_ff @(posedge clk or posedge reset) begin
		if (reset)
			tailAddr <= 4'h0;
		else if(needToRestore_i)
			tailAddr <= 4'h0;
		else if ((ifNew&LSretire)|(~LSretire&tailAddr==4'hF)|(~ifNew&tailAddr==4'h0))
			tailAddr <= tailAddr;
		else if (LSretire)
			tailAddr <= tailAddr-1;
		else if (ifNew)
			tailAddr <= tailAddr+1;
		else
			tailAddr <= tailAddr;
	end
	assign full = &tailAddr; //full when tail above queue
	assign PCout = so0[198:135];
endmodule




/*
module loadStoreQueue_testbench();
	wire full, flush, forwards;
	wire [63:0] PCout, valOut;
	reg loadOrStore, ifNew, ifAddrWrite, ifValWrite, LSretire, reset, clk;
	reg [63:0] PCin, addrWrite, valWrite;
	reg [4:0] ROBin, addrWriteROB, valWriteROB;
	loadStoreQueue DUT(.full, .flush, .PCout, .loadOrStore, .PCin, .ROBin, .ifNew, .addrWrite, .addrWriteROB, .ifAddrWrite, .valWrite, .LSretire, .forwards, .valOut, .reset, .clk);
	
	initial begin
		reset=1;	clk=0;
		loadOrStore=1;	ifNew=0;	PCin=64'h100;	ROBin=4'h0;	ifAddrWrite=0;	addrWrite=64'h10;	addrWriteROB=4'h0;	valWrite=64'hFA;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;	reset=0;
		loadOrStore=0;	ifNew=1;	PCin=64'h100;	ROBin=4'h6;	ifAddrWrite=0;	addrWrite=64'h10;	addrWriteROB=4'h0;	valWrite=64'hFA;	LSretire=0; //start with stores
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=0;	ifNew=1;	PCin=64'h104;	ROBin=4'h7;	ifAddrWrite=0;	addrWrite=64'h10;	addrWriteROB=4'h0;	valWrite=64'hFA;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=0;	ifNew=1;	PCin=64'h108;	ROBin=4'h8;	ifAddrWrite=1;	addrWrite=64'h0;	addrWriteROB=4'h6;	valWrite=64'hFA;	LSretire=0; //first address write
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=1;	PCin=64'h10C;	ROBin=4'h1;	ifAddrWrite=1;	addrWrite=64'h8;	addrWriteROB=4'h7;	valWrite=64'hFA;	LSretire=0; //first load
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=1;	PCin=64'h110;	ROBin=4'h2;	ifAddrWrite=1;	addrWrite=64'h10;	addrWriteROB=4'h8;	valWrite=64'hFA;	LSretire=1;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=1;	PCin=64'h114;	ROBin=4'h3;	ifAddrWrite=1;	addrWrite=64'h10;	addrWriteROB=4'h1;	valWrite=64'hFA;	LSretire=1;
		#5;	clk=1;	#5;	clk=0;
		
		
		loadOrStore=1;	ifNew=0;	PCin=64'h118;	ROBin=4'hA;	ifAddrWrite=1;	addrWrite=64'h0;	addrWriteROB=4'h2;	valWrite=64'hFA;	LSretire=1;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=0;	PCin=64'h11C;	ROBin=4'h0;	ifAddrWrite=1;	addrWrite=64'h8;	addrWriteROB=4'h3;	valWrite=64'hFA;	LSretire=1;
		#5;	clk=1;	#5;	clk=0;
		
		LSretire=1;
		#5;	clk=1;	#5;	clk=0;		#5;	clk=1;	#5;	clk=0;		#5;	clk=1;	#5;	clk=0;
		#5;	clk=1;	#5;	clk=0;		#5;	clk=1;	#5;	clk=0;		#5;	clk=1;	#5;	clk=0;
	end
	
	initial begin
		ifValWrite=0;	valWrite=64'h0;	valWriteROB=0; //never change, dead val ports for now
		reset=1;	clk=0;
		loadOrStore=1;	ifNew=0;	PCin=64'h100;	ROBin=4'h0;	ifAddrWrite=0;	addrWrite=64'h10;	addrWriteROB=4'h0;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;	reset=0;
		loadOrStore=1;	ifNew=0;	PCin=64'h100;	ROBin=4'h0;	ifAddrWrite=0;	addrWrite=64'h10;	addrWriteROB=4'h0;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=0;	PCin=64'h100;	ROBin=4'h0;	ifAddrWrite=0;	addrWrite=64'h10;	addrWriteROB=4'h0;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=1;	PCin=64'h104;	ROBin=4'h2;	ifAddrWrite=0;	addrWrite=64'h10;	addrWriteROB=4'h0;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=1;	PCin=64'h108;	ROBin=4'h4;	ifAddrWrite=0;	addrWrite=64'h10;	addrWriteROB=4'h0;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=0;	ifNew=1;	PCin=64'h10C;	ROBin=4'h6;	ifAddrWrite=0;	addrWrite=64'h10;	addrWriteROB=4'h0;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=1;	PCin=64'h110;	ROBin=4'h8;	ifAddrWrite=0;	addrWrite=64'h10;	addrWriteROB=4'h0;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=1;	PCin=64'h114;	ROBin=4'hA;	ifAddrWrite=0;	addrWrite=64'h10;	addrWriteROB=4'h0;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=0;	PCin=64'h100;	ROBin=4'h0;	ifAddrWrite=1;	addrWrite=64'h10;	addrWriteROB=4'h6;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=0;	PCin=64'h100;	ROBin=4'h0;	ifAddrWrite=1;	addrWrite=64'h11;	addrWriteROB=4'h2;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=0;	PCin=64'h100;	ROBin=4'h0;	ifAddrWrite=1;	addrWrite=64'h13;	addrWriteROB=4'h8;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=0;	PCin=64'h100;	ROBin=4'h0;	ifAddrWrite=1;	addrWrite=64'h15;	addrWriteROB=4'hA;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=0;	PCin=64'h100;	ROBin=4'h0;	ifAddrWrite=1;	addrWrite=64'h19;	addrWriteROB=4'h4;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=1;	PCin=64'h118;	ROBin=4'hD;	ifAddrWrite=1;	addrWrite=64'h1C;	addrWriteROB=4'h0;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		loadOrStore=1;	ifNew=0;	PCin=64'h100;	ROBin=4'h0;	ifAddrWrite=1;	addrWrite=64'h10;	addrWriteROB=4'hD;	LSretire=0;
		#5;	clk=1;	#5;	clk=0;
		LSretire=1;
		#5;	clk=1;	#5;	clk=0;		#5;	clk=1;	#5;	clk=0;		#5;	clk=1;	#5;	clk=0;
		#5;	clk=1;	#5;	clk=0;		#5;	clk=1;	#5;	clk=0;		#5;	clk=1;	#5;	clk=0;
	end
endmodule*/

