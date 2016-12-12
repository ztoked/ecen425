

#define STARTVAL 1001		/* must be an odd # */
#define ENDVAL   100000

main()
{
    int i,j,flag,lncnt;
    printf("Primes between %d and %d:\n", STARTVAL, ENDVAL);
    lncnt = 0;
    for (i = STARTVAL; i < ENDVAL; i += 2)
    {
	flag = 0;
	for (j = 3; (j*j) < i; j += 2)
	{
	    if (i % j == 0)
	    {
		flag = 1;
		break;
	    }
	}
	if (!flag)
	{
	    printf(" %d", i);
	    lncnt++;
	    if (lncnt > 9)
	    {
		printf("\n");
		lncnt = 0;
	    }
	}
    }
    printf("\n");
}
	
	
	
