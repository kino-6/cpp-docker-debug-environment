/**
 * @file startup_stm32f4xx.s
 * @brief Startup file for STM32F407VG
 * @author Embedded Development Template
 */

.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

/* Vector Table */
.section .isr_vector,"a",%progbits
.type g_pfnVectors, %object
.size g_pfnVectors, .-g_pfnVectors

g_pfnVectors:
    .word _estack                    /* Top of Stack */
    .word Reset_Handler              /* Reset Handler */
    .word NMI_Handler                /* NMI Handler */
    .word HardFault_Handler          /* Hard Fault Handler */
    .word MemManage_Handler          /* MPU Fault Handler */
    .word BusFault_Handler           /* Bus Fault Handler */
    .word UsageFault_Handler         /* Usage Fault Handler */
    .word 0                          /* Reserved */
    .word 0                          /* Reserved */
    .word 0                          /* Reserved */
    .word 0                          /* Reserved */
    .word SVC_Handler                /* SVCall Handler */
    .word DebugMon_Handler           /* Debug Monitor Handler */
    .word 0                          /* Reserved */
    .word PendSV_Handler             /* PendSV Handler */
    .word SysTick_Handler            /* SysTick Handler */

    /* External Interrupts */
    .word WWDG_IRQHandler            /* Window WatchDog */
    .word PVD_IRQHandler             /* PVD through EXTI Line detection */
    .word TAMP_STAMP_IRQHandler      /* Tamper and TimeStamps through the EXTI line */
    .word RTC_WKUP_IRQHandler        /* RTC Wakeup through the EXTI line */
    .word FLASH_IRQHandler           /* FLASH */
    .word RCC_IRQHandler             /* RCC */
    .word EXTI0_IRQHandler           /* EXTI Line0 */
    .word EXTI1_IRQHandler           /* EXTI Line1 */
    .word EXTI2_IRQHandler           /* EXTI Line2 */
    .word EXTI3_IRQHandler           /* EXTI Line3 */
    .word EXTI4_IRQHandler           /* EXTI Line4 */
    .word DMA1_Stream0_IRQHandler    /* DMA1 Stream 0 */
    .word DMA1_Stream1_IRQHandler    /* DMA1 Stream 1 */
    .word DMA1_Stream2_IRQHandler    /* DMA1 Stream 2 */
    .word DMA1_Stream3_IRQHandler    /* DMA1 Stream 3 */
    .word DMA1_Stream4_IRQHandler    /* DMA1 Stream 4 */
    .word DMA1_Stream5_IRQHandler    /* DMA1 Stream 5 */
    .word DMA1_Stream6_IRQHandler    /* DMA1 Stream 6 */
    .word ADC_IRQHandler             /* ADC1, ADC2 and ADC3s */

/* Reset Handler */
.section .text.Reset_Handler
.weak Reset_Handler
.type Reset_Handler, %function
Reset_Handler:
    ldr sp, =_estack    /* Set stack pointer */

    /* Copy the data segment initializers from flash to SRAM */
    movs r1, #0
    b LoopCopyDataInit

CopyDataInit:
    ldr r3, =_sidata
    ldr r3, [r3, r1]
    str r3, [r0, r1]
    adds r1, r1, #4

LoopCopyDataInit:
    ldr r0, =_sdata
    ldr r3, =_edata
    adds r2, r0, r1
    cmp r2, r3
    bcc CopyDataInit
    ldr r2, =_sbss
    b LoopFillZerobss

/* Zero fill the bss segment */
FillZerobss:
    movs r3, #0
    str r3, [r2], #4

LoopFillZerobss:
    ldr r3, = _ebss
    cmp r2, r3
    bcc FillZerobss

    /* Call the application's entry point */
    bl main

LoopForever:
    b LoopForever

.size Reset_Handler, .-Reset_Handler

/* Default interrupt handlers */
.section .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
    b Infinite_Loop
.size Default_Handler, .-Default_Handler

/* Weak definitions for interrupt handlers */
.weak NMI_Handler
.thumb_set NMI_Handler,Default_Handler

.weak HardFault_Handler
.thumb_set HardFault_Handler,Default_Handler

.weak MemManage_Handler
.thumb_set MemManage_Handler,Default_Handler

.weak BusFault_Handler
.thumb_set BusFault_Handler,Default_Handler

.weak UsageFault_Handler
.thumb_set UsageFault_Handler,Default_Handler

.weak SVC_Handler
.thumb_set SVC_Handler,Default_Handler

.weak DebugMon_Handler
.thumb_set DebugMon_Handler,Default_Handler

.weak PendSV_Handler
.thumb_set PendSV_Handler,Default_Handler

.weak SysTick_Handler
.thumb_set SysTick_Handler,Default_Handler

.weak WWDG_IRQHandler
.thumb_set WWDG_IRQHandler,Default_Handler

.weak PVD_IRQHandler
.thumb_set PVD_IRQHandler,Default_Handler

.weak TAMP_STAMP_IRQHandler
.thumb_set TAMP_STAMP_IRQHandler,Default_Handler

.weak RTC_WKUP_IRQHandler
.thumb_set RTC_WKUP_IRQHandler,Default_Handler

.weak FLASH_IRQHandler
.thumb_set FLASH_IRQHandler,Default_Handler

.weak RCC_IRQHandler
.thumb_set RCC_IRQHandler,Default_Handler

.weak EXTI0_IRQHandler
.thumb_set EXTI0_IRQHandler,Default_Handler

.weak EXTI1_IRQHandler
.thumb_set EXTI1_IRQHandler,Default_Handler

.weak EXTI2_IRQHandler
.thumb_set EXTI2_IRQHandler,Default_Handler

.weak EXTI3_IRQHandler
.thumb_set EXTI3_IRQHandler,Default_Handler

.weak EXTI4_IRQHandler
.thumb_set EXTI4_IRQHandler,Default_Handler

.weak DMA1_Stream0_IRQHandler
.thumb_set DMA1_Stream0_IRQHandler,Default_Handler

.weak DMA1_Stream1_IRQHandler
.thumb_set DMA1_Stream1_IRQHandler,Default_Handler

.weak DMA1_Stream2_IRQHandler
.thumb_set DMA1_Stream2_IRQHandler,Default_Handler

.weak DMA1_Stream3_IRQHandler
.thumb_set DMA1_Stream3_IRQHandler,Default_Handler

.weak DMA1_Stream4_IRQHandler
.thumb_set DMA1_Stream4_IRQHandler,Default_Handler

.weak DMA1_Stream5_IRQHandler
.thumb_set DMA1_Stream5_IRQHandler,Default_Handler

.weak DMA1_Stream6_IRQHandler
.thumb_set DMA1_Stream6_IRQHandler,Default_Handler

.weak ADC_IRQHandler
.thumb_set ADC_IRQHandler,Default_Handler