event_inherited();

code = @'-- count down from 10000
let n = 10000
while (n > 0) {
    log n
    n = it - 1
}
return "blast off!"';

desc = "This example computes the factorial of four numbers and outputs " +
        "their result to the log window.";