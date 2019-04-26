//io_handler.c
#include "io_handler.h"
#include "system.h"
#include <stdio.h>

void IO_init(void)
{
	*otg_hpi_reset = 1;
	*otg_hpi_cs = 1;
	*otg_hpi_r = 1;
	*otg_hpi_w = 1;
	*otg_hpi_address = 0;
	*otg_hpi_data = 0;
	// Reset OTG chip
	*otg_hpi_cs = 0;
	*otg_hpi_reset = 0;
	*otg_hpi_reset = 1;
	*otg_hpi_cs = 1;
}

void IO_write(alt_u8 Address, alt_u16 Data)
{

	*otg_hpi_address = Address;

	//Set the cs and write flags to low to be able ro write
	*otg_hpi_cs = 0; //Set CS low (ON)
	*otg_hpi_w = 0;

	*otg_hpi_data = Data;


	//Reset the cs and write flags to high
	*otg_hpi_cs = 1;
	*otg_hpi_w = 1;
}

alt_u16 IO_read(alt_u8 Address)
{
	alt_u16 temp;


	*otg_hpi_address = Address;

	//Set the cs and read flags to low to be able ro write
	*otg_hpi_cs = 0; //Set CS low (ON)
	*otg_hpi_r = 0;


	temp = *otg_hpi_data;

	//Reset the cs and read flags to high
	*otg_hpi_cs = 1;
	*otg_hpi_r = 1;

	return temp;
}
