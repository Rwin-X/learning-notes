"use strict";

/*
 * JavaScript Functions - Part 1: Basics
 *
 * Run:   node 01-basics.js
 * Needs: Node.js 16 or newer, no dependencies.
 *
 * Topics: declarations, calls, parameters, defaults, rest/spread, return values,
 * function expressions, arrow functions, hoisting, scope, small utilities.
 * Every example prints its result, so run the file and read the output next to
 * the source.
 */

let exampleNumber = 0;

function demo(title, body) {
  exampleNumber += 1;
  console.log("\n[" + String(exampleNumber).padStart(2, "0") + "] " + title);
  body();
}

// ---------------------------------------------------------------------------
// A. Declaring and calling
// ---------------------------------------------------------------------------

demo("Declare and call a function", () => {
  function sayHello() {
    console.log("Hello, world!");
  }
  sayHello();
  sayHello();
});

demo("Parameters and arguments", () => {
  function greet(name, greeting) {
    console.log(greeting + ", " + name + "!");
  }
  greet("Sara", "Hello");
  greet("Ali", "Good evening");
});

demo("Return a value", () => {
  function add(a, b) {
    return a + b;
  }
  const total = add(2, 3);
  console.log("add(2, 3) =", total);
  console.log("add(add(1, 2), 4) =", add(add(1, 2), 4));
});

demo("A function without return gives undefined", () => {
  function noReturn() {
    const x = 1 + 1; // computed but never returned
  }
  console.log(noReturn()); // undefined
});

demo("Reference vs call", () => {
  function getTime() {
    return "12:00";
  }
  console.log(typeof getTime);   // function
  console.log(getTime());        // 12:00
  const alias = getTime;         // no parentheses: copies the reference
  console.log(alias());          // 12:00
});

demo("return stops execution", () => {
  function firstNegative(numbers) {
    for (const n of numbers) {
      if (n < 0) {
        return n; // leaves the function immediately
      }
    }
    return null;
  }
  console.log(firstNegative([4, 8, -3, 9, -1])); // -3
  console.log(firstNegative([1, 2, 3]));         // null
});

// ---------------------------------------------------------------------------
// B. Parameters in depth
// ---------------------------------------------------------------------------

demo("Missing and extra arguments", () => {
  function show(a, b) {
    console.log("a =", a, "| b =", b);
  }
  show(1);        // b is undefined
  show(1, 2, 3);  // 3 is ignored
});

demo("Default parameters", () => {
  function power(base, exponent = 2) {
    return base ** exponent;
  }
  console.log(power(5));    // 25
  console.log(power(2, 10)); // 1024
});

demo("Defaults can use earlier parameters and expressions", () => {
  function createUser(name, role = "guest", id = name.toLowerCase() + "_001") {
    return { name, role, id };
  }
  console.log(createUser("Sara"));
  console.log(createUser("Ali", "admin"));
  console.log(createUser("Reza", "editor", "custom_id"));
});

demo("Defaults apply only to undefined", () => {
  function show(value = "fallback") {
    console.log(JSON.stringify(value));
  }
  show(undefined); // "fallback"
  show(null);      // null
  show(0);         // 0
  show("");        // ""
});

demo("Rest parameters", () => {
  function sum(...numbers) {
    return numbers.reduce((total, n) => total + n, 0);
  }
  console.log(sum());              // 0
  console.log(sum(5));             // 5
  console.log(sum(1, 2, 3, 4, 5)); // 15

  function log(level, ...messages) {
    console.log("[" + level + "]", messages.join(" "));
  }
  log("INFO", "server", "started", "on", "port", 3000);
});

demo("Spread in a call", () => {
  const scores = [72, 91, 85];
  console.log(Math.max(...scores)); // 91
  console.log(Math.min(...scores)); // 72
  console.log(Math.max(...scores, 100)); // 100
});

demo("The arguments object (regular functions only)", () => {
  function describeArguments() {
    console.log("count:", arguments.length);
    console.log("is array:", Array.isArray(arguments));
    console.log("as array:", Array.from(arguments));
  }
  describeArguments("a", "b", "c");
});

demo("Destructuring an object parameter (named arguments)", () => {
  function createAccount({ owner, balance = 0, currency = "USD" } = {}) {
    return owner + " has " + balance + " " + currency;
  }
  console.log(createAccount({ owner: "Sara", balance: 250 }));
  console.log(createAccount({ owner: "Ali", currency: "EUR" }));
});

demo("Destructuring an array parameter", () => {
  function distance([x1, y1], [x2, y2]) {
    return Math.hypot(x2 - x1, y2 - y1);
  }
  console.log(distance([0, 0], [3, 4])); // 5
});

demo("Primitives are copied, objects are shared", () => {
  function increment(n) {
    n += 1;
    return n;
  }
  function rename(user) {
    user.name = "Changed";
  }
  function replace(user) {
    user = { name: "Replaced" }; // rebinding the local variable only
    return user;
  }

  let value = 10;
  increment(value);
  console.log("value after increment:", value); // 10

  const account = { name: "Original" };
  rename(account);
  console.log("after rename:", account.name);   // Changed
  replace(account);
  console.log("after replace:", account.name);  // Changed
});

// ---------------------------------------------------------------------------
// C. Return values
// ---------------------------------------------------------------------------

demo("Guard clauses (early return)", () => {
  function safeDivide(a, b) {
    if (typeof a !== "number" || typeof b !== "number") {
      return null;
    }
    if (b === 0) {
      return null;
    }
    return a / b;
  }
  console.log(safeDivide(10, 4));   // 2.5
  console.log(safeDivide(1, 0));    // null
  console.log(safeDivide("1", 2));  // null
});

demo("Return several values with an object or an array", () => {
  function minMax(numbers) {
    return { min: Math.min(...numbers), max: Math.max(...numbers) };
  }
  const { min, max } = minMax([4, 9, 1, 7]);
  console.log("min:", min, "max:", max);

  function divmod(a, b) {
    return [Math.floor(a / b), a % b];
  }
  const [quotient, remainder] = divmod(17, 5);
  console.log("17 / 5 =", quotient, "remainder", remainder);
});

demo("Automatic semicolon insertion after return", () => {
  function broken() {
    return
    { ok: true };
  }
  function fixed() {
    return {
      ok: true,
    };
  }
  console.log(broken()); // undefined
  console.log(fixed());  // { ok: true }
});

// ---------------------------------------------------------------------------
// D. Other ways to define functions
// ---------------------------------------------------------------------------

demo("Function expression", () => {
  const multiply = function (a, b) {
    return a * b;
  };
  console.log(multiply(6, 7)); // 42
});

demo("Named function expression", () => {
  const factorial = function fact(n) {
    return n <= 1 ? 1 : n * fact(n - 1);
  };
  console.log(factorial(6));         // 720
  console.log(factorial.name);       // fact
  console.log(typeof fact);          // undefined (name is private to the function)
});

demo("Arrow function forms", () => {
  const add = (a, b) => {
    return a + b;
  };
  const addShort = (a, b) => a + b;
  const square = x => x * x;
  const pi = () => 3.14159;
  console.log(add(1, 2), addShort(1, 2), square(9), pi());
});

demo("Arrow function returning an object literal", () => {
  const makePoint = (x, y) => ({ x, y });
  console.log(makePoint(3, 4)); // { x: 3, y: 4 }
});

demo("Methods in an object", () => {
  const calculator = {
    total: 0,
    add(n) {
      this.total += n;
      return this;
    },
    subtract(n) {
      this.total -= n;
      return this;
    },
    result() {
      return this.total;
    },
  };
  console.log(calculator.add(10).subtract(3).add(5).result()); // 12
});

demo("Functions stored in arrays and objects (dispatch table)", () => {
  const operations = {
    add: (a, b) => a + b,
    subtract: (a, b) => a - b,
    multiply: (a, b) => a * b,
    divide: (a, b) => (b === 0 ? NaN : a / b),
  };
  for (const name of Object.keys(operations)) {
    console.log(name + "(12, 4) =", operations[name](12, 4));
  }
  const pipeline = [x => x + 1, x => x * 2, x => x - 3];
  let value = 5;
  for (const step of pipeline) {
    value = step(value);
  }
  console.log("pipeline result:", value); // ((5 + 1) * 2) - 3 = 9
});

demo("Function properties: name and length", () => {
  function example(a, b, c = 3, ...rest) {}
  console.log(example.name);   // example
  console.log(example.length); // 2 (counts parameters before the first default/rest)
  console.log((() => {}).name === ""); // true: an anonymous arrow has an empty name
  const inferred = () => {};
  console.log(inferred.name);  // inferred (name taken from the variable)
});

// ---------------------------------------------------------------------------
// E. Hoisting and scope
// ---------------------------------------------------------------------------

demo("Declarations are hoisted", () => {
  console.log(early("Ali")); // works before the definition
  function early(name) {
    return "Hi, " + name;
  }
});

demo("Function expressions are not hoisted", () => {
  try {
    late();
  } catch (error) {
    console.log(error.name + ": " + error.message);
  }
  const late = function () {
    return "ready";
  };
  console.log(late());
});

demo("var is function scoped, let is block scoped", () => {
  function scopes() {
    if (true) {
      var visible = "var leaks out of the block";
      let hidden = "let stays inside the block";
    }
    console.log(visible);
    try {
      console.log(hidden);
    } catch (error) {
      console.log(error.name + ": " + error.message);
    }
  }
  scopes();
});

demo("Lexical scope and shadowing", () => {
  const label = "global";
  function outer() {
    const label = "outer";           // shadows the outer variable
    function inner() {
      return label;                  // finds the nearest one
    }
    return inner();
  }
  console.log(outer()); // outer
  console.log(label);   // global
});

demo("this in a plain function call (strict mode)", () => {
  function whoAmI() {
    return this;
  }
  console.log(whoAmI()); // undefined in strict mode
});

// ---------------------------------------------------------------------------
// F. Callbacks
// ---------------------------------------------------------------------------

demo("Passing a function as an argument", () => {
  function repeat(times, action) {
    for (let i = 0; i < times; i++) {
      action(i);
    }
  }
  repeat(3, index => console.log("step", index));
});

demo("Returning a function", () => {
  function multiplier(factor) {
    return number => number * factor;
  }
  const double = multiplier(2);
  const triple = multiplier(3);
  console.log(double(8), triple(8)); // 16 24
});

demo("Custom comparator for sort", () => {
  const people = [
    { name: "Sara", age: 31 },
    { name: "Ali", age: 25 },
    { name: "Reza", age: 28 },
  ];
  const byAge = [...people].sort((a, b) => a.age - b.age);
  const byName = [...people].sort((a, b) => a.name.localeCompare(b.name));
  console.log(byAge.map(p => p.name).join(", "));  // Ali, Reza, Sara
  console.log(byName.map(p => p.name).join(", ")); // Ali, Reza, Sara
});

// ---------------------------------------------------------------------------
// G. Small utility functions (practice)
// ---------------------------------------------------------------------------

demo("Utility: isEven, clamp, average", () => {
  const isEven = n => n % 2 === 0;
  const clamp = (value, min, max) => Math.min(Math.max(value, min), max);
  const average = numbers =>
    numbers.length === 0 ? 0 : numbers.reduce((s, n) => s + n, 0) / numbers.length;

  console.log(isEven(10), isEven(7));       // true false
  console.log(clamp(15, 0, 10), clamp(-5, 0, 10), clamp(5, 0, 10)); // 10 0 5
  console.log(average([2, 4, 6, 8]));       // 5
});

demo("Utility: isPrime and primes up to n", () => {
  function isPrime(n) {
    if (n < 2) return false;
    for (let i = 2; i * i <= n; i++) {
      if (n % i === 0) return false;
    }
    return true;
  }
  function primesUpTo(limit) {
    const result = [];
    for (let n = 2; n <= limit; n++) {
      if (isPrime(n)) result.push(n);
    }
    return result;
  }
  console.log(primesUpTo(30).join(" ")); // 2 3 5 7 11 13 17 19 23 29
});

demo("Utility: FizzBuzz", () => {
  function fizzBuzz(n) {
    if (n % 15 === 0) return "FizzBuzz";
    if (n % 3 === 0) return "Fizz";
    if (n % 5 === 0) return "Buzz";
    return String(n);
  }
  const output = [];
  for (let i = 1; i <= 15; i++) {
    output.push(fizzBuzz(i));
  }
  console.log(output.join(" "));
});

demo("Utility: string helpers", () => {
  const reverse = text => [...text].reverse().join("");
  const capitalize = text => (text ? text[0].toUpperCase() + text.slice(1) : text);
  const countWords = text => text.trim().split(/\s+/).filter(Boolean).length;
  const slugify = text =>
    text.toLowerCase().trim().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");

  console.log(reverse("function"));              // noitcnuf
  console.log(capitalize("javascript"));         // Javascript
  console.log(countWords("  one two   three ")); // 3
  console.log(slugify("  Hello, World! JS 2026 ")); // hello-world-js-2026
});

demo("Utility: temperature and unit conversion", () => {
  const celsiusToFahrenheit = c => (c * 9) / 5 + 32;
  const fahrenheitToCelsius = f => ((f - 32) * 5) / 9;
  console.log(celsiusToFahrenheit(100)); // 212
  console.log(fahrenheitToCelsius(32));  // 0
  console.log(celsiusToFahrenheit(36.6).toFixed(1)); // 97.9
});

demo("Utility: gcd and lcm", () => {
  const gcd = (a, b) => (b === 0 ? a : gcd(b, a % b));
  const lcm = (a, b) => (a / gcd(a, b)) * b;
  console.log(gcd(48, 18)); // 6
  console.log(lcm(4, 6));   // 12
});

console.log("\nDone: " + exampleNumber + " examples.");
