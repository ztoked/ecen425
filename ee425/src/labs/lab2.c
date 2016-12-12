#include <stdio.h>

int k;

void a()
{
    static int i = 0;
    int j = 0;
    
    i++;
    j++;
    printf("in a(), i = %d, j = %d\n", i, j);
}

void b()
{
    printf("in b()\n");
    a();
}

int fibonacci(int n)
{
    if (n == 1)
	return 1;
    else if (n == 2)
	return 2;
    else
	return fibonacci(n-1) + fibonacci(n-2);
}

void main()
{
    a();
    b();
    for (k = 1; k <= 10; k++)
	printf("Fibonnaci number %d is %d\n", k, fibonacci(k));
}
