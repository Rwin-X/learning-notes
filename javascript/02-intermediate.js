"use strict";

/*
 * JavaScript Functions - Part 2: Intermediate
 *
 * Run:   node 02-intermediate.js
 * Needs: Node.js 16 or newer, no dependencies.
 *
 * Topics: closures, higher-order functions, array pipelines, recursion,
 * this / call / apply / bind, constructors, classes, IIFE and the module pattern.
 */

let exampleNumber = 0;

function demo(title, body) {
  exampleNumber += 1;
  console.log("\n[" + String(exampleNumber).padStart(2, "0") + "] " + title);
  body();
}

// ---------------------------------------------------------------------------
// A. Closures
// ---------------------------------------------------------------------------

demo("Closure: a counter with private state", () => {
  function createCounter(start = 0) {
    let count = start;
    return () => ++count;
  }
  const a = createCounter();
  const b = createCounter(100);
  console.log(a(), a(), a()); // 1 2 3
  console.log(b(), b());      // 101 102
});

demo("Closure: private data with public methods", () => {
  function createWallet(initial) {
    let balance = initial;
    return {
      deposit(amount) {
        if (amount <= 0) throw new Error("Amount must be positive");
        balance += amount;
        return balance;
      },
      withdraw(amount) {
        if (amount > balance) throw new Error("Insufficient funds");
        balance -= amount;
        return balance;
      },
      get balance() {
        return balance;
      },
    };
  }
  const wallet = createWallet(100);
  wallet.deposit(50);
  wallet.withdraw(30);
  console.log("balance:", wallet.balance); // 120
  try {
    wallet.withdraw(500);
  } catch (error) {
    console.log("error:", error.message);
  }
});

demo("Closure: function factory", () => {
  const makeGreeter = greeting => name => greeting + ", " + name + "!";
  const hello = makeGreeter("Hello");
  const salam = makeGreeter("Salam");
  console.log(hello("Sara"));
  console.log(salam("Ali"));
});

demo("Closure: loops with var and let", () => {
  const withVar = [];
  for (var i = 0; i < 3; i++) {
    withVar.push(() => i);
  }
  const withLet = [];
  for (let j = 0; j < 3; j++) {
    withLet.push(() => j);
  }
  console.log("var:", withVar.map(fn => fn())); // [ 3, 3, 3 ]
  console.log("let:", withLet.map(fn => fn())); // [ 0, 1, 2 ]
});

demo("Closure: remember the last call", () => {
  function createTracker() {
    let last = null;
    return function track(value) {
      const previous = last;
      last = value;
      return previous;
    };
  }
  const track = createTracker();
  console.log(track("a")); // null
  console.log(track("b")); // a
  console.log(track("c")); // b
});

demo("Closure: configuration builder", () => {
  function createLogger(prefix, level = "info") {
    const levels = ["debug", "info", "warn", "error"];
    const threshold = levels.indexOf(level);
    return function log(messageLevel, message) {
      if (levels.indexOf(messageLevel) >= threshold) {
        console.log("[" + prefix + "][" + messageLevel + "] " + message);
      }
    };
  }
  const log = createLogger("app", "warn");
  log("debug", "hidden");
  log("info", "hidden");
  log("warn", "disk almost full");
  log("error", "connection lost");
});

// ---------------------------------------------------------------------------
// B. Higher-order functions and array pipelines
// ---------------------------------------------------------------------------

demo("Build map, filter and reduce yourself", () => {
  function myMap(items, fn) {
    const result = [];
    for (let i = 0; i < items.length; i++) result.push(fn(items[i], i, items));
    return result;
  }
  function myFilter(items, predicate) {
    const result = [];
    for (let i = 0; i < items.length; i++) {
      if (predicate(items[i], i, items)) result.push(items[i]);
    }
    return result;
  }
  function myReduce(items, reducer, initial) {
    let accumulator = initial;
    for (let i = 0; i < items.length; i++) {
      accumulator = reducer(accumulator, items[i], i, items);
    }
    return accumulator;
  }
  const numbers = [1, 2, 3, 4, 5];
  console.log(myMap(numbers, n => n * 10));          // [ 10, 20, 30, 40, 50 ]
  console.log(myFilter(numbers, n => n % 2 === 1));  // [ 1, 3, 5 ]
  console.log(myReduce(numbers, (a, n) => a + n, 0)); // 15
});

demo("map, filter, reduce, find, some, every", () => {
  const numbers = [1, 2, 3, 4, 5, 6];
  console.log(numbers.map(n => n * 2));
  console.log(numbers.filter(n => n % 2 === 0));
  console.log(numbers.reduce((sum, n) => sum + n, 0));
  console.log(numbers.find(n => n > 3));
  console.log(numbers.findIndex(n => n > 3));
  console.log(numbers.some(n => n > 5), numbers.every(n => n > 0));
});

demo("Chaining: sum of squares of even numbers", () => {
  const result = [1, 2, 3, 4, 5, 6]
    .filter(n => n % 2 === 0)
    .map(n => n * n)
    .reduce((a, b) => a + b, 0);
  console.log(result); // 56
});

demo("Processing a list of objects", () => {
  const products = [
    { name: "Keyboard", price: 45, category: "hardware", stock: 12 },
    { name: "Mouse", price: 20, category: "hardware", stock: 0 },
    { name: "Editor License", price: 80, category: "software", stock: 100 },
    { name: "Monitor", price: 210, category: "hardware", stock: 4 },
  ];
  const available = products.filter(p => p.stock > 0);
  const names = available.map(p => p.name);
  const totalValue = available.reduce((sum, p) => sum + p.price * p.stock, 0);
  console.log(names);
  console.log("inventory value:", totalValue);
  const cheapest = products.reduce((min, p) => (p.price < min.price ? p : min));
  console.log("cheapest:", cheapest.name);
});

demo("groupBy, countBy, unique", () => {
  const groupBy = (items, keyFn) =>
    items.reduce((groups, item) => {
      const key = keyFn(item);
      (groups[key] = groups[key] || []).push(item);
      return groups;
    }, {});
  const countBy = (items, keyFn) =>
    items.reduce((counts, item) => {
      const key = keyFn(item);
      counts[key] = (counts[key] || 0) + 1;
      return counts;
    }, {});
  const unique = items => [...new Set(items)];

  const words = ["apple", "avocado", "banana", "blueberry", "cherry", "apple"];
  console.log(groupBy(words, w => w[0]));
  console.log(countBy(words, w => w.length));
  console.log(unique(words));
});

demo("zip, chunk, partition", () => {
  const zip = (a, b) => a.map((item, i) => [item, b[i]]);
  const chunk = (items, size) => {
    const chunks = [];
    for (let i = 0; i < items.length; i += size) chunks.push(items.slice(i, i + size));
    return chunks;
  };
  const partition = (items, predicate) =>
    items.reduce(
      ([pass, fail], item) => (predicate(item) ? [[...pass, item], fail] : [pass, [...fail, item]]),
      [[], []]
    );

  console.log(zip(["a", "b", "c"], [1, 2, 3]));
  console.log(chunk([1, 2, 3, 4, 5, 6, 7], 3));
  console.log(partition([1, 2, 3, 4, 5, 6], n => n % 2 === 0));
});

demo("Sort by several keys", () => {
  const people = [
    { name: "Sara", city: "Berlin", age: 31 },
    { name: "Ali", city: "Berlin", age: 25 },
    { name: "Reza", city: "Munich", age: 31 },
    { name: "Nima", city: "Munich", age: 25 },
  ];
  const sorted = [...people].sort(
    (a, b) => a.city.localeCompare(b.city) || b.age - a.age || a.name.localeCompare(b.name)
  );
  sorted.forEach(p => console.log(p.city, p.age, p.name));
});

demo("flatMap, Object.entries and Object.fromEntries", () => {
  const sentences = ["hello world", "functions are values"];
  console.log(sentences.flatMap(s => s.split(" ")));

  const prices = { apple: 2, pear: 3, plum: 5 };
  const discounted = Object.fromEntries(
    Object.entries(prices).map(([name, price]) => [name, price * 0.5])
  );
  console.log(discounted);
});

demo("Functions that take and return functions", () => {
  const not = predicate => (...args) => !predicate(...args);
  const both = (f, g) => (...args) => f(...args) && g(...args);
  const isEven = n => n % 2 === 0;
  const isPositive = n => n > 0;
  const isOdd = not(isEven);
  const isPositiveEven = both(isPositive, isEven);
  console.log([1, 2, 3, 4, -2, -3].filter(isOdd));          // [ 1, 3, -3 ]
  console.log([1, 2, 3, 4, -2, -3].filter(isPositiveEven)); // [ 2, 4 ]
});

demo("Callback pitfall: map with parseInt", () => {
  console.log(["1", "2", "3"].map(parseInt));            // [ 1, NaN, NaN ]
  console.log(["1", "2", "3"].map(Number));              // [ 1, 2, 3 ]
  console.log(["1", "2", "3"].map(s => parseInt(s, 10))); // [ 1, 2, 3 ]
});

// ---------------------------------------------------------------------------
// C. Recursion
// ---------------------------------------------------------------------------

demo("Recursion: factorial, power, sum of an array", () => {
  const factorial = n => (n <= 1 ? 1 : n * factorial(n - 1));
  const power = (base, exp) => (exp === 0 ? 1 : base * power(base, exp - 1));
  const sumArray = ([head, ...tail]) => (head === undefined ? 0 : head + sumArray(tail));
  console.log(factorial(10));          // 3628800
  console.log(power(2, 10));           // 1024
  console.log(sumArray([1, 2, 3, 4])); // 10
});

demo("Recursion: Fibonacci three ways", () => {
  const fibNaive = n => (n < 2 ? n : fibNaive(n - 1) + fibNaive(n - 2));

  const fibMemo = (() => {
    const cache = new Map();
    const fib = n => {
      if (n < 2) return n;
      if (cache.has(n)) return cache.get(n);
      const value = fib(n - 1) + fib(n - 2);
      cache.set(n, value);
      return value;
    };
    return fib;
  })();

  function fibLoop(n) {
    let [previous, current] = [0, 1];
    for (let i = 0; i < n; i++) [previous, current] = [current, previous + current];
    return previous;
  }
  console.log(fibNaive(20), fibMemo(20), fibLoop(20)); // 6765 6765 6765
  console.log(fibMemo(80), fibLoop(80));                // 23416728348467685 23416728348467685
});

demo("Recursion: flatten and deep clone", () => {
  const flatten = items =>
    items.reduce((flat, item) => flat.concat(Array.isArray(item) ? flatten(item) : item), []);
  console.log(flatten([1, [2, [3, [4, [5]]]], 6])); // [ 1, 2, 3, 4, 5, 6 ]

  function deepClone(value) {
    if (value === null || typeof value !== "object") return value;
    if (value instanceof Date) return new Date(value.getTime());
    if (Array.isArray(value)) return value.map(deepClone);
    const copy = {};
    for (const key of Object.keys(value)) copy[key] = deepClone(value[key]);
    return copy;
  }
  const original = { name: "Sara", tags: ["a", "b"], nested: { level: 1 } };
  const copy = deepClone(original);
  copy.nested.level = 99;
  copy.tags.push("c");
  console.log(original); // unchanged
  console.log(copy);
});

demo("Recursion: permutations and subsets", () => {
  function permutations(items) {
    if (items.length <= 1) return [items];
    const result = [];
    items.forEach((item, index) => {
      const rest = [...items.slice(0, index), ...items.slice(index + 1)];
      for (const tail of permutations(rest)) result.push([item, ...tail]);
    });
    return result;
  }
  function subsets(items) {
    if (items.length === 0) return [[]];
    const [first, ...rest] = items;
    const withoutFirst = subsets(rest);
    return [...withoutFirst, ...withoutFirst.map(s => [first, ...s])];
  }
  console.log(permutations([1, 2, 3]).map(p => p.join("")).join(" "));
  console.log(subsets(["a", "b", "c"]).map(s => "{" + s.join(",") + "}").join(" "));
});

demo("Recursion: Tower of Hanoi", () => {
  function hanoi(n, from, to, via, moves = []) {
    if (n === 0) return moves;
    hanoi(n - 1, from, via, to, moves);
    moves.push(from + "->" + to);
    hanoi(n - 1, via, to, from, moves);
    return moves;
  }
  console.log(hanoi(3, "A", "C", "B").join(" "));
  console.log("moves for 10 disks:", hanoi(10, "A", "C", "B").length); // 1023
});

demo("Recursion: binary search and walking a tree", () => {
  function binarySearch(sorted, target, low = 0, high = sorted.length - 1) {
    if (low > high) return -1;
    const mid = Math.floor((low + high) / 2);
    if (sorted[mid] === target) return mid;
    return sorted[mid] < target
      ? binarySearch(sorted, target, mid + 1, high)
      : binarySearch(sorted, target, low, mid - 1);
  }
  console.log(binarySearch([1, 3, 5, 7, 9, 11, 13], 9));  // 4
  console.log(binarySearch([1, 3, 5, 7, 9, 11, 13], 4));  // -1

  const tree = {
    name: "root",
    children: [
      { name: "src", children: [{ name: "index.js", children: [] }, { name: "util.js", children: [] }] },
      { name: "README.md", children: [] },
    ],
  };
  function printTree(node, depth = 0) {
    console.log("  ".repeat(depth) + node.name);
    node.children.forEach(child => printTree(child, depth + 1));
  }
  printTree(tree);
  const countNodes = node => 1 + node.children.reduce((sum, c) => sum + countNodes(c), 0);
  console.log("nodes:", countNodes(tree)); // 5
});

demo("Recursion: stack overflow and how to avoid it", () => {
  const sumTo = n => (n === 0 ? 0 : n + sumTo(n - 1));
  try {
    sumTo(1000000);
  } catch (error) {
    console.log(error.name); // RangeError
  }
  const sumToLoop = n => {
    let total = 0;
    for (let i = 1; i <= n; i++) total += i;
    return total;
  };
  console.log(sumToLoop(1000000)); // 500000500000
});

// ---------------------------------------------------------------------------
// D. this, call, apply, bind, constructors, classes
// ---------------------------------------------------------------------------

demo("this in a method call", () => {
  const user = {
    name: "Sara",
    greet() {
      return "Hi, I am " + this.name;
    },
  };
  console.log(user.greet());
});

demo("Losing this and fixing it", () => {
  const user = {
    name: "Sara",
    greet() {
      return "Hi, I am " + this.name;
    },
  };
  const detached = user.greet;
  try {
    detached();
  } catch (error) {
    console.log("detached:", error.name);
  }
  console.log("bind:", user.greet.bind(user)());
  console.log("arrow wrapper:", (() => user.greet())());
  console.log("call:", user.greet.call({ name: "Ali" }));
});

demo("call, apply, bind", () => {
  function introduce(greeting, punctuation) {
    return greeting + ", I am " + this.name + punctuation;
  }
  const person = { name: "Ali" };
  console.log(introduce.call(person, "Hello", "!"));
  console.log(introduce.apply(person, ["Hi", "."]));
  const bound = introduce.bind(person, "Hey");
  console.log(bound("?"));
});

demo("Borrowing methods", () => {
  const arrayLike = { 0: "a", 1: "b", 2: "c", length: 3 };
  console.log(Array.prototype.map.call(arrayLike, x => x.toUpperCase())); // [ 'A', 'B', 'C' ]
  console.log(Math.max.apply(null, [4, 8, 2]));                           // 8
});

demo("Arrow functions keep the outer this", () => {
  const timer = {
    seconds: 0,
    tickAll(times) {
      [...Array(times)].forEach(() => {
        this.seconds += 1; // arrow: "this" is timer
      });
      return this.seconds;
    },
  };
  console.log(timer.tickAll(5)); // 5
});

demo("Constructor function and prototype", () => {
  function Person(name, age) {
    this.name = name;
    this.age = age;
  }
  Person.prototype.describe = function () {
    return this.name + " is " + this.age;
  };
  const a = new Person("Sara", 30);
  const b = new Person("Ali", 25);
  console.log(a.describe(), "|", b.describe());
  console.log(a.describe === b.describe); // true: shared on the prototype
  try {
    Person("Oops", 1); // forgot "new"
  } catch (error) {
    console.log("without new:", error.name);
  }
});

demo("Class with getter, setter, static method and private field", () => {
  class Temperature {
    #celsius;
    static fromFahrenheit(f) {
      return new Temperature(((f - 32) * 5) / 9);
    }
    constructor(celsius) {
      this.#celsius = celsius;
    }
    get celsius() {
      return this.#celsius;
    }
    set celsius(value) {
      if (typeof value !== "number") throw new TypeError("Number expected");
      this.#celsius = value;
    }
    get fahrenheit() {
      return (this.#celsius * 9) / 5 + 32;
    }
    toString() {
      return this.#celsius.toFixed(1) + " C";
    }
  }
  const t = new Temperature(25);
  console.log(String(t), t.fahrenheit);
  t.celsius = 30;
  console.log(String(t));
  console.log(String(Temperature.fromFahrenheit(212))); // 100.0 C
});

demo("Inheritance with extends and super", () => {
  class Shape {
    constructor(name) {
      this.name = name;
    }
    area() {
      return 0;
    }
    describe() {
      return this.name + " with area " + this.area().toFixed(2);
    }
  }
  class Circle extends Shape {
    constructor(radius) {
      super("Circle");
      this.radius = radius;
    }
    area() {
      return Math.PI * this.radius ** 2;
    }
  }
  class Rectangle extends Shape {
    constructor(width, height) {
      super("Rectangle");
      this.width = width;
      this.height = height;
    }
    area() {
      return this.width * this.height;
    }
  }
  [new Circle(2), new Rectangle(3, 4)].forEach(shape => console.log(shape.describe()));
});

demo("Fluent interface (method chaining)", () => {
  class QueryBuilder {
    constructor(table) {
      this.table = table;
      this.conditions = [];
      this.limitValue = null;
    }
    where(condition) {
      this.conditions.push(condition);
      return this;
    }
    limit(count) {
      this.limitValue = count;
      return this;
    }
    build() {
      let query = "SELECT * FROM " + this.table;
      if (this.conditions.length) query += " WHERE " + this.conditions.join(" AND ");
      if (this.limitValue !== null) query += " LIMIT " + this.limitValue;
      return query;
    }
  }
  console.log(new QueryBuilder("users").where("age > 18").where("active = 1").limit(10).build());
});

// ---------------------------------------------------------------------------
// E. IIFE, module pattern, error-first callbacks
// ---------------------------------------------------------------------------

demo("IIFE: private scope", () => {
  const result = (function () {
    const secret = 42;
    return secret * 2;
  })();
  console.log(result); // 84
  console.log(typeof secret); // undefined: not visible outside
});

demo("Module pattern", () => {
  const idGenerator = (() => {
    let current = 0;
    return {
      next: () => ++current,
      reset: () => {
        current = 0;
      },
    };
  })();
  console.log(idGenerator.next(), idGenerator.next(), idGenerator.next());
  idGenerator.reset();
  console.log(idGenerator.next());
});

demo("Error-first callbacks (synchronous simulation)", () => {
  function parseJson(text, callback) {
    let data;
    try {
      data = JSON.parse(text);
    } catch (error) {
      return callback(error);
    }
    callback(null, data);
  }
  parseJson('{"ok": true}', (error, data) => {
    console.log(error ? "failed: " + error.message : "parsed: " + JSON.stringify(data));
  });
  parseJson("{broken", (error, data) => {
    console.log(error ? "failed: " + error.name : "parsed: " + JSON.stringify(data));
  });
});

demo("Currying by hand and with closures", () => {
  const add = a => b => c => a + b + c;
  console.log(add(1)(2)(3)); // 6
  const addTen = add(10);
  console.log(addTen(5)(5)); // 20
  const discount = rate => price => price * (1 - rate);
  const tenPercentOff = discount(0.1);
  console.log([100, 250, 40].map(tenPercentOff)); // [ 90, 225, 36 ]
});

console.log("\nDone: " + exampleNumber + " examples.");
