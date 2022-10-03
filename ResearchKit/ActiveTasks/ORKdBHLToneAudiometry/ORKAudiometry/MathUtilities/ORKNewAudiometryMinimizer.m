/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
// apple-internal

#if RK_APPLE_INTERNAL

#import "ORKNewAudiometryMinimizer.h"
#include "lbfgsb.h"

@implementation ORKNewAudiometryMinimizer

static NSLock *mutex;

- (NSArray<NSNumber *> *)minimizeThetaX:(double)thetaX thetaY:(double)thetaY onFunction:(MinimizableFunction)function {
    if (!mutex) {
        mutex = [[NSLock alloc] init];
    }
    [mutex lock];
    
    static integer lowerXBound = 5;
    static integer upperXBound = 35;
    static integer lowerYBound = 2;
    static integer upperYBound = 35;
    
    static integer maxIteration = 300;
    static double gradientDelta = 1;
    static double x1 = 0, dx = 0, f1 = 0, df = 0;
        
    /* Local variables */
    static double f = 0, g[8] = {0};
    static double l[1024] = {0};
    static double u[1024] = {0}, x[8] = {0}, wa[43251] = {0};
    static integer nbd[1024] = {0}, iwa[3072] = {0};
    
    static integer taskValue = 0;
    static integer *task=&taskValue;
    static integer csaveValue = 0;
    static integer *csave=&csaveValue;
    
    static double dsave[29] = {0};
    static integer isave[44] = {0};
    static logical lsave[4] = {0};

    /*   Disable debug logs   */
    static integer iprint = -1;
    
/*     We specify the tolerances in the stopping criteria. */
    static double factr = 1e7;
    static double pgtol = 1e-5;
    
/*     We specify the dimension n of the sample problem and the number */
/*        m of limited memory corrections stored.  (n and m should not */
/*        exceed the limits nmax and mmax respectively.) */
    static integer n = 2;
    static integer m = 10;
    
/*     We now provide nbd which defines the bounds on the variables: */
    nbd[0] = 2;
    nbd[1] = 2;

    /*     Next set bounds on the variables. */
    l[0] = lowerXBound;
    u[0] = upperXBound;
    l[1] = lowerYBound;
    u[1] = upperYBound;

    /*     We now define the starting point. */
    x[0] = thetaX;
    x[0] = x[0] < l[0] ? l[0] : x[0];
    x[0] = x[0] > u[0] ? u[0] : x[0];
    
    x[1] = thetaY;
    x[1] = x[1] < l[1] ? l[1] : x[1];
    x[1] = x[1] > u[1] ? u[1] : x[1];

    /*     We start the iteration by initializing task. */
    *task = (integer)START;
    
    /*        ------- the beginning of the loop ---------- */
    while (1) {
        
        /*     This is the call to the L-BFGS-B code. */
        setulb(&n, &m, x, l, u, nbd, &f, g, &factr, &pgtol, wa, iwa, task, &
               iprint, csave, lsave, isave, dsave);
        
        if ( IS_FG(*task) ) {
            /*        the minimization routine has returned to request the */
            /*        function f and gradient g values at the current x. */
            /*        Compute function value f for the sample problem. */
            f = function(x[0], x[1]);
            
            /*        Compute gradient g for the sample problem. */
            x1 = x[0] + gradientDelta;
            dx = x1 - x[0];
            f1 = function(x1, x[1]);
            df = f1 - f;
            g[0] = df / dx;
            
            x1 = x[1] + gradientDelta;
            dx = x1 - x[1];
            f1 = function(x[0], x1);
            df = f1 - f;
            g[1] = df / dx;
            
            /*          go back to the minimization routine. */
        } else if ( *task==NEW_X ) {
            
            if (dsave[12] <= (fabs(f) + 1.0) * 1e-7) {
                /*    Terminate if  |proj g|/(1+|f|) < 1.0d-7.    */
                *task = STOP_GRAD;
                
            } else if (isave[33] >= maxIteration) {
                /*        ------- limit number of loops ---------- */
                *task = (integer)STOP_ITER;
            }
        } else {
            /*        ------- end minimization when task is not FG or NEW_X ---------- */
            break;
        }
    }
    
    [mutex unlock];
//    NSLog(@"\nTheta = [%lf	%lf]		F = %lf", x[0], x[1], function(x[0],x[1]));
    return @[[NSNumber numberWithDouble:x[0]], [NSNumber numberWithDouble:x[1]]];
}

@end

#endif
