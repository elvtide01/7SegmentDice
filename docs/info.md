<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The system is intended to recreate the effect of a rolling dice as an instrument to generate random numbers between 1 to 6 after hitting a input button. After releasing the button, the counter that initally counts in a rapid way decreases it's counting speed to simulate a roll-off effect. After the dice finally finishes counting, an external LED signalizes that the user can start to read the resulting number.

## How to test

Press one button to start the counter and keep it pressed for a certain time (for example 2 seconds). Release the button and after approx. 7 seconds the number on the 7-segment display shows you a random number in the range of 1 to 6.

## External hardware

- 2 LEDs connected as active low
- 1 7-segment display in common-anode configuration (or 2-digit 7-segment display connected to PMOD, whereas only one of the digits is used)
- 2 buttons - one for software-reset and one to let the dice roll.
