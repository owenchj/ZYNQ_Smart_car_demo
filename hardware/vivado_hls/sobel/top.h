/***************************************************************************

*   © Copyright 2013 Xilinx, Inc. All rights reserved. 

*   This file contains confidential and proprietary information of Xilinx,
*   Inc. and is protected under U.S. and international copyright and other
*   intellectual property laws. 

*   DISCLAIMER
*   This disclaimer is not a license and does not grant any rights to the
*   materials distributed herewith. Except as otherwise provided in a valid
*   license issued to you by Xilinx, and to the maximum extent permitted by
*   applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH
*   ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, 
*   EXPRESS, IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES
*   OF MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR 
*   PURPOSE; and (2) Xilinx shall not be liable (whether in contract or 
*   tort, including negligence, or under any other theory of liability)
*   for any loss or damage of any kind or nature related to, arising under
*   or in connection with these materials, including for any direct, or any
*   indirect, special, incidental, or consequential loss or damage (including
*   loss of data, profits, goodwill, or any type of loss or damage suffered 
*   as a result of any action brought by a third party) even if such damage
*   or loss was reasonably foreseeable or Xilinx had been advised of the 
*   possibility of the same. 

*   CRITICAL APPLICATIONS 
*   Xilinx products are not designed or intended to be fail-safe, or for use
*   in any application requiring fail-safe performance, such as life-support
*   or safety devices or systems, Class III medical devices, nuclear facilities,
*   applications related to the deployment of airbags, or any other applications
*   that could lead to death, personal injury, or severe property or environmental
*   damage (individually and collectively, "Critical Applications"). Customer
*   assumes the sole risk and liability of any use of Xilinx products in Critical
*   Applications, subject only to applicable laws and regulations governing 
*   limitations on product liability. 

*   THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT 
*   ALL TIMES.

***************************************************************************/

#ifndef _TOP_H_
#define _TOP_H_

#include "hls_video.h"

// maximum image size
#define MAX_WIDTH  640
#define MAX_HEIGHT 480

#define ABSDIFF(x,y)	((x>y)? x - y : y - x)
#define ABS(x)          ((x>0)? x : -x)

// typedef video library core structures
typedef hls::stream<ap_axiu<24,1,1,1> >               AXI_STREAM;
typedef hls::stream<ap_axiu<8,1,1,1> >                Y_STREAM;
typedef hls::Scalar<3, unsigned char>                 RGB_PIXEL;
typedef hls::Scalar<1, unsigned char>                 Y_PIXEL;
typedef hls::Mat<MAX_HEIGHT, MAX_WIDTH, HLS_8UC3>     RGB_IMAGE;
typedef hls::Mat<MAX_HEIGHT, MAX_WIDTH, HLS_8UC1>     Y_IMAGE;
typedef hls::Window<3, 3, unsigned char>              Y_WINDOW;
typedef hls::LineBuffer<3, MAX_WIDTH, unsigned char>  Y_BUFFER;

// top level function for HW synthesis
void sobel(AXI_STREAM& INPUT_STREAM, Y_STREAM& OUTPUT_STREAM, int rows, int cols,
                  int C_XR0C0, int C_XR0C1, int C_XR0C2, int C_XR1C0, int C_XR1C1, int C_XR1C2, int C_XR2C0, int C_XR2C1, int C_XR2C2,
                  int C_YR0C0, int C_YR0C1, int C_YR0C2, int C_YR1C0, int C_YR1C1, int C_YR1C2, int C_YR2C0, int C_YR2C1, int C_YR2C2,
                  int c_high_thresh, int c_low_thresh, int c_invert, int threshold);

#endif
