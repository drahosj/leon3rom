#include "soc.h"
#include <string.h>

char buf[5] = {'x', 'y', 'z', '\n', '\0'};
int global_int;

/* Linker symbols */
extern int _erodata;
extern int _data;
extern int _edata;
extern int _bss;
extern int _ebss;

void leon_putc(char c)
{
      volatile unsigned int * uart = (unsigned int *) UART_BASE;
      while (!(uart[1] & 0x04)) {}
      uart[0] = c;
}

void leon_puts(char *s)
{
      while (*s) {
            leon_putc(*(s++));
      }
}

void printhex(char c)
{
      char t = (c & 0xf0) >> 4;
      t += 0x30;
      if (t >0x39) {
            t += 7;
      }
      leon_putc(t);

      t = c & 0x0f;
      t += 0x30;
      if (t >0x39) {
            t += 7;
      }
      leon_putc(t);
}

void recurse(char i)
{
      leon_puts("Recursion: ");
      printhex(i);
      leon_putc('\n');

      if (i) {
            recurse(i - 1);
            leon_puts("Returned to: ");
            printhex(i);
            leon_putc('\n');
      }
      leon_puts("Returning\n");
      return;
}

void printword(unsigned int p)
{
      printhex((p & 0xff000000) >> 24);
      printhex((p & 0x00ff0000) >> 16);
      printhex((p & 0x0000ff00) >> 8);
      printhex(p & 0x000000ff);
}

void copy_data()
{
      leon_puts("Copy data...\n");
      if (&_erodata == &_data) {
            leon_puts("Copy data not needed, loaded to RAM?\n");
            return;
      }

      int len = (&_edata - &_data) / 4;
      int * p = &_erodata;
      int * q = &_data;
      int i;
      for (i = 0; i < len; i++) {
            q[i] = p[i];
      } 
}

void zero_bss()
{
      leon_puts("Zero bss...\n");
      unsigned int len = (&_ebss - &_bss);
      leon_puts("Length (words) of BSS: ");
      printword(len);
      leon_putc('\n');
      int * p = &_bss;
      unsigned int i;
      for (i = 0; i < len; i++) {
            leon_puts("Zeroing: ");
            printword((unsigned int) p);
            leon_putc('\n');
            p[i] = 0;
      }
}

int c_start()
{
      copy_data();
      zero_bss();
      leon_puts("Hello, world (from C)\n");
      char buf[64] = "Hello string on stack.\n";
      leon_puts(buf);
      leon_puts("after stack1\n");
      char * foo = "Second stack string\n";
      int i;
      for (i = 0; foo[i] != '\n'; i++) {
            buf[i] = foo[i];
      }
      buf[i] = '\0';
      leon_puts(buf);
      leon_puts("After stack access\n");
      leon_puts("\n&buf: ");
      printword((unsigned int) buf);

      leon_puts("Calling Recursion (2)\n");
      recurse(2);

      leon_puts("Calling Recursion (4)\n");
      recurse(4);

      leon_puts("Calling Recursion (8)\n");
      recurse(8);

      leon_puts("Calling Recursion (16)\n");
      recurse(16);

      leon_puts("Did recursion!\n");

      buf[0] = 'a';
      buf[1] = 'b';
      buf[2] = 'c';
      leon_puts("printing buf\n");
      leon_puts(buf);
      leon_puts("printed buf\n");
      global_int++;
      printword(global_int);

}
