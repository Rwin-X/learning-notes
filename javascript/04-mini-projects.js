"use strict";

/*
 * JavaScript Functions - Part 4: Mini projects
 *
 * Run:   node 04-mini-projects.js
 * Needs: Node.js 16 or newer, no dependencies.
 *
 * Each project is small, self-contained and built mainly from functions:
 *  1. Todo store (reducer + subscribe)        7. Token-bucket rate limiter
 *  2. LRU cache                               8. Template engine with filters
 *  3. Expression calculator (parser)          9. Dependency resolver (topological sort)
 *  4. URL router with path parameters        10. Shopping cart as a pure pipeline
 *  5. Text analyzer                          11. Mini reactive system (signals)
 *  6. Bank account with custom errors        12. Priority job scheduler
 *                                            13. Mini test framework
 */

const projects = [];
function project(title, body) {
  projects.push({ title, body });
}
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

// ---------------------------------------------------------------------------
project("Todo store: reducer, dispatch, subscribe", () => {
  function createStore(reducer, initialState) {
    let state = initialState;
    const listeners = new Set();
    return {
      getState: () => state,
      dispatch(action) {
        state = reducer(state, action);
        listeners.forEach(listener => listener(state));
        return action;
      },
      subscribe(listener) {
        listeners.add(listener);
        return () => listeners.delete(listener);
      },
    };
  }

  const initial = { items: [], nextId: 1 };
  function todosReducer(state = initial, action) {
    switch (action.type) {
      case "add":
        return {
          items: [...state.items, { id: state.nextId, text: action.text, done: false }],
          nextId: state.nextId + 1,
        };
      case "toggle":
        return {
          ...state,
          items: state.items.map(item => (item.id === action.id ? { ...item, done: !item.done } : item)),
        };
      case "remove":
        return { ...state, items: state.items.filter(item => item.id !== action.id) };
      default:
        return state;
    }
  }

  const remaining = state => state.items.filter(item => !item.done).length;
  const store = createStore(todosReducer, initial);
  const unsubscribe = store.subscribe(state => console.log("  state changed, remaining:", remaining(state)));

  store.dispatch({ type: "add", text: "Learn closures" });
  store.dispatch({ type: "add", text: "Learn recursion" });
  store.dispatch({ type: "add", text: "Build a project" });
  store.dispatch({ type: "toggle", id: 1 });
  store.dispatch({ type: "remove", id: 2 });
  unsubscribe();
  store.dispatch({ type: "toggle", id: 3 }); // no log: unsubscribed
  console.log(store.getState().items);
});

// ---------------------------------------------------------------------------
project("LRU cache", () => {
  function createLRUCache(capacity) {
    const map = new Map();
    return {
      get(key) {
        if (!map.has(key)) return undefined;
        const value = map.get(key);
        map.delete(key);
        map.set(key, value); // mark as most recently used
        return value;
      },
      set(key, value) {
        if (map.has(key)) map.delete(key);
        map.set(key, value);
        if (map.size > capacity) {
          const oldest = map.keys().next().value;
          map.delete(oldest);
          console.log("  evicted:", oldest);
        }
      },
      keys: () => [...map.keys()],
    };
  }
  const cache = createLRUCache(3);
  cache.set("a", 1);
  cache.set("b", 2);
  cache.set("c", 3);
  cache.get("a");        // "a" becomes most recent
  cache.set("d", 4);     // evicts "b"
  console.log(cache.keys()); // [ 'c', 'a', 'd' ]
  console.log(cache.get("b")); // undefined
});

// ---------------------------------------------------------------------------
project("Expression calculator (tokenizer + recursive descent parser)", () => {
  function tokenize(text) {
    const tokens = [];
    let i = 0;
    while (i < text.length) {
      const ch = text[i];
      if (/\s/.test(ch)) {
        i += 1;
      } else if (/[0-9.]/.test(ch)) {
        let digits = "";
        while (i < text.length && /[0-9.]/.test(text[i])) digits += text[i++];
        tokens.push({ type: "number", value: parseFloat(digits) });
      } else if ("+-*/^()".includes(ch)) {
        tokens.push({ type: ch });
        i += 1;
      } else {
        throw new SyntaxError("Unexpected character '" + ch + "' at position " + i);
      }
    }
    return tokens;
  }

  // Grammar:
  //   expression -> term (("+" | "-") term)*
  //   term       -> unary (("*" | "/") unary)*
  //   unary      -> "-" unary | power
  //   power      -> primary ("^" unary)?
  //   primary    -> number | "(" expression ")"
  function evaluate(text) {
    const tokens = tokenize(text);
    let position = 0;
    const peek = () => tokens[position];
    const next = () => tokens[position++];
    const isType = (...types) => peek() !== undefined && types.includes(peek().type);

    function expression() {
      let left = term();
      while (isType("+", "-")) {
        const operator = next().type;
        const right = term();
        left = operator === "+" ? left + right : left - right;
      }
      return left;
    }
    function term() {
      let left = unary();
      while (isType("*", "/")) {
        const operator = next().type;
        const right = unary();
        if (operator === "/" && right === 0) throw new RangeError("Division by zero");
        left = operator === "*" ? left * right : left / right;
      }
      return left;
    }
    function unary() {
      if (isType("-")) {
        next();
        return -unary();
      }
      return power();
    }
    function power() {
      const base = primary();
      if (isType("^")) {
        next();
        return base ** unary();
      }
      return base;
    }
    function primary() {
      const token = next();
      if (!token) throw new SyntaxError("Unexpected end of input");
      if (token.type === "number") return token.value;
      if (token.type === "(") {
        const value = expression();
        if (!isType(")")) throw new SyntaxError("Missing closing parenthesis");
        next();
        return value;
      }
      throw new SyntaxError("Unexpected token '" + token.type + "'");
    }

    const result = expression();
    if (position < tokens.length) throw new SyntaxError("Unexpected token '" + peek().type + "'");
    return result;
  }

  const inputs = ["2 + 3 * (4 - 1) ^ 2", "-2 ^ 2", "2 ^ 3 ^ 2", "10 / 4", "(1 + 2", "1 / 0", "2 $ 3"];
  for (const input of inputs) {
    try {
      console.log("  " + input + " = " + evaluate(input));
    } catch (error) {
      console.log("  " + input + " -> " + error.name + ": " + error.message);
    }
  }
});

// ---------------------------------------------------------------------------
project("URL router with path parameters", () => {
  function createRouter() {
    const routes = [];
    const compile = pattern => {
      const keys = [];
      const source = pattern.replace(/:([A-Za-z_]+)/g, (_, key) => {
        keys.push(key);
        return "([^/]+)";
      });
      return { regex: new RegExp("^" + source + "$"), keys };
    };
    return {
      add(method, pattern, handler) {
        routes.push({ method, ...compile(pattern), handler });
        return this;
      },
      handle(method, url) {
        const [path, queryString = ""] = url.split("?");
        for (const route of routes) {
          if (route.method !== method) continue;
          const match = route.regex.exec(path);
          if (!match) continue;
          const params = Object.fromEntries(route.keys.map((key, i) => [key, decodeURIComponent(match[i + 1])]));
          const query = Object.fromEntries(new URLSearchParams(queryString));
          return route.handler({ params, query });
        }
        return { status: 404, body: "Not found: " + method + " " + path };
      },
    };
  }

  const router = createRouter()
    .add("GET", "/users", () => ({ status: 200, body: "all users" }))
    .add("GET", "/users/:id", ({ params }) => ({ status: 200, body: "user " + params.id }))
    .add("GET", "/users/:id/posts/:postId", ({ params, query }) => ({
      status: 200,
      body: "post " + params.postId + " of user " + params.id + " page=" + (query.page || "1"),
    }));

  console.log(router.handle("GET", "/users"));
  console.log(router.handle("GET", "/users/42"));
  console.log(router.handle("GET", "/users/42/posts/7?page=3"));
  console.log(router.handle("POST", "/users"));
  console.log(router.handle("GET", "/missing"));
});

// ---------------------------------------------------------------------------
project("Text analyzer", () => {
  const text = "The quick brown fox jumps over the lazy dog. The fox, however, was not amused!";
  const words = text.toLowerCase().match(/[a-z']+/g) || [];

  const countBy = (items, keyFn) =>
    items.reduce((counts, item) => {
      const key = keyFn(item);
      counts[key] = (counts[key] || 0) + 1;
      return counts;
    }, {});
  const topN = (counts, n) =>
    Object.entries(counts)
      .sort(([wordA, a], [wordB, b]) => b - a || wordA.localeCompare(wordB))
      .slice(0, n);
  const longest = items => items.reduce((best, word) => (word.length > best.length ? word : best), "");
  const average = numbers => numbers.reduce((s, n) => s + n, 0) / numbers.length;

  console.log("words:", words.length);
  console.log("unique:", new Set(words).size);
  console.log("top 3:", topN(countBy(words, w => w), 3));
  console.log("longest:", longest(words));
  console.log("average length:", average(words.map(w => w.length)).toFixed(2));
  console.log("by length:", countBy(words, w => w.length));
});

// ---------------------------------------------------------------------------
project("Bank account with custom errors", () => {
  class InsufficientFundsError extends Error {
    constructor(needed, available) {
      super("Need " + needed + " but only " + available + " available");
      this.name = "InsufficientFundsError";
    }
  }
  function createAccount(owner, opening = 0) {
    let balance = opening;
    const history = [];
    const record = (type, amount) => history.push({ type, amount, balance });
    return {
      deposit(amount) {
        if (!(amount > 0)) throw new RangeError("Deposit must be positive");
        balance += amount;
        record("deposit", amount);
        return balance;
      },
      withdraw(amount) {
        if (!(amount > 0)) throw new RangeError("Withdrawal must be positive");
        if (amount > balance) throw new InsufficientFundsError(amount, balance);
        balance -= amount;
        record("withdraw", amount);
        return balance;
      },
      statement() {
        return history.map(h => h.type.padEnd(8) + String(h.amount).padStart(6) + " -> " + h.balance);
      },
      get owner() {
        return owner;
      },
      get balance() {
        return balance;
      },
    };
  }
  const account = createAccount("Sara", 100);
  account.deposit(50);
  account.withdraw(30);
  for (const attempt of [() => account.withdraw(500), () => account.deposit(-5)]) {
    try {
      attempt();
    } catch (error) {
      console.log("  " + error.name + ": " + error.message);
    }
  }
  console.log(account.statement().join("\n"));
  console.log("final balance:", account.balance);
});

// ---------------------------------------------------------------------------
project("Token-bucket rate limiter with an injectable clock", () => {
  function createRateLimiter({ capacity, refillPerSecond, now = Date.now }) {
    let tokens = capacity;
    let last = now();
    return function tryAcquire() {
      const current = now();
      tokens = Math.min(capacity, tokens + ((current - last) / 1000) * refillPerSecond);
      last = current;
      if (tokens >= 1) {
        tokens -= 1;
        return true;
      }
      return false;
    };
  }
  let fakeTime = 0; // a fake clock makes the behavior testable and deterministic
  const tryAcquire = createRateLimiter({ capacity: 3, refillPerSecond: 1, now: () => fakeTime });
  const burst = Array.from({ length: 5 }, () => tryAcquire());
  console.log("burst at t=0s:", burst.join(" "));      // true true true false false
  fakeTime += 2000;
  const later = Array.from({ length: 3 }, () => tryAcquire());
  console.log("after 2 seconds:", later.join(" "));    // true true false
});

// ---------------------------------------------------------------------------
project("Template engine with nested paths and filters", () => {
  function render(template, data, filters = {}) {
    return template.replace(/\{\{\s*([\w.]+)(?:\s*\|\s*(\w+))?\s*\}\}/g, (match, path, filterName) => {
      const value = path.split(".").reduce((object, key) => (object == null ? undefined : object[key]), data);
      if (value === undefined) return "";
      const filter = filterName ? filters[filterName] : undefined;
      return filter ? filter(value) : String(value);
    });
  }
  const filters = {
    upper: value => String(value).toUpperCase(),
    money: value => "$" + Number(value).toFixed(2),
  };
  const template = "Hello, {{ user.name | upper }}! Your total is {{ order.total | money }} ({{ order.items }} items). {{ missing }}";
  console.log(render(template, { user: { name: "Sara" }, order: { total: 41.5, items: 3 } }, filters));
});

// ---------------------------------------------------------------------------
project("Dependency resolver (topological sort with cycle detection)", () => {
  function resolveOrder(graph) {
    const order = [];
    const state = new Map(); // "visiting" | "done"
    function visit(node, path) {
      if (state.get(node) === "done") return;
      if (state.get(node) === "visiting") {
        throw new Error("Cycle detected: " + [...path, node].join(" -> "));
      }
      state.set(node, "visiting");
      for (const dependency of graph[node] || []) visit(dependency, [...path, node]);
      state.set(node, "done");
      order.push(node);
    }
    Object.keys(graph).forEach(node => visit(node, []));
    return order;
  }
  const modules = { app: ["ui", "api"], ui: ["utils"], api: ["utils", "db"], db: [], utils: [] };
  console.log("build order:", resolveOrder(modules).join(" > "));
  try {
    resolveOrder({ a: ["b"], b: ["c"], c: ["a"] });
  } catch (error) {
    console.log(error.message);
  }
});

// ---------------------------------------------------------------------------
project("Shopping cart as a pure pipeline", () => {
  const pipe = (...fns) => input => fns.reduce((acc, fn) => fn(acc), input);

  const subtotal = cart => cart.reduce((sum, item) => sum + item.price * item.qty, 0);
  const applyVolumeDiscount = total => (total >= 100 ? total * 0.9 : total);
  const addTax = rate => total => total * (1 + rate);
  const roundMoney = value => Math.round(value * 100) / 100;

  const priceCart = pipe(subtotal, applyVolumeDiscount, addTax(0.08), roundMoney);

  const cart = [
    { sku: "A", price: 20, qty: 2 },
    { sku: "B", price: 5.5, qty: 4 },
    { sku: "C", price: 100, qty: 1 },
  ];
  console.log("subtotal:", subtotal(cart));          // 162
  console.log("final price:", priceCart(cart));      // 157.46
  console.log("small cart:", priceCart([{ sku: "A", price: 20, qty: 1 }])); // 21.6
  console.log("cart unchanged:", cart.length === 3);
});

// ---------------------------------------------------------------------------
project("Mini reactive system (signals and effects)", () => {
  let activeEffect = null;
  function createSignal(initial) {
    let value = initial;
    const subscribers = new Set();
    const read = () => {
      if (activeEffect) subscribers.add(activeEffect);
      return value;
    };
    const write = next => {
      if (Object.is(next, value)) return;
      value = next;
      [...subscribers].forEach(run => run());
    };
    return [read, write];
  }
  function createEffect(fn) {
    const run = () => {
      const previous = activeEffect;
      activeEffect = run;
      try {
        fn();
      } finally {
        activeEffect = previous;
      }
    };
    run();
  }
  function createComputed(fn) {
    const [read, write] = createSignal(undefined);
    createEffect(() => write(fn()));
    return read;
  }

  const [price, setPrice] = createSignal(10);
  const [quantity, setQuantity] = createSignal(2);
  const total = createComputed(() => price() * quantity());

  createEffect(() => console.log("  total is now", total()));
  setQuantity(5);
  setPrice(12);
  setPrice(12); // same value: no update
});

// ---------------------------------------------------------------------------
project("Priority job scheduler with a concurrency limit", async () => {
  function createScheduler(concurrency) {
    const pending = [];
    let running = 0;
    let started = false;
    let order = 0;
    const startOrder = [];
    let finishAll;
    const allDone = new Promise(resolve => (finishAll = resolve));

    function pump() {
      if (!started) return;
      while (running < concurrency && pending.length > 0) {
        pending.sort((a, b) => b.priority - a.priority || a.order - b.order);
        const job = pending.shift();
        running += 1;
        startOrder.push(job.name);
        job.task().then(job.resolve, job.reject).finally(() => {
          running -= 1;
          pump();
          if (running === 0 && pending.length === 0) finishAll(startOrder);
        });
      }
    }
    return {
      add(name, priority, task) {
        return new Promise((resolve, reject) => {
          pending.push({ name, priority, task, resolve, reject, order: order++ });
        });
      },
      start() {
        started = true;
        pump();
        return allDone;
      },
    };
  }
  const scheduler = createScheduler(2);
  const job = name => async () => {
    await sleep(10);
    return name + " done";
  };
  const results = [
    scheduler.add("low-1", 1, job("low-1")),
    scheduler.add("high-1", 10, job("high-1")),
    scheduler.add("mid-1", 5, job("mid-1")),
    scheduler.add("high-2", 10, job("high-2")),
    scheduler.add("low-2", 1, job("low-2")),
  ];
  const startOrder = await scheduler.start();
  console.log("start order:", startOrder.join(" > "));
  console.log("results:", (await Promise.all(results)).join(", "));
});

// ---------------------------------------------------------------------------
project("Mini test framework", async () => {
  function createTestRunner() {
    const tests = [];
    const format = value => JSON.stringify(value);
    const it = (name, fn) => tests.push({ name, fn });
    const expect = actual => ({
      toBe(expected) {
        if (!Object.is(actual, expected)) {
          throw new Error("expected " + format(expected) + " but received " + format(actual));
        }
      },
      toEqual(expected) {
        if (format(actual) !== format(expected)) {
          throw new Error("expected " + format(expected) + " but received " + format(actual));
        }
      },
      toThrow(ErrorType = Error) {
        try {
          actual();
        } catch (error) {
          if (!(error instanceof ErrorType)) throw new Error("threw the wrong error type: " + error.name);
          return;
        }
        throw new Error("expected the function to throw");
      },
    });
    async function run() {
      let passed = 0;
      for (const { name, fn } of tests) {
        try {
          await fn();
          passed += 1;
          console.log("  PASS  " + name);
        } catch (error) {
          console.log("  FAIL  " + name + " -> " + error.message);
        }
      }
      console.log("  " + passed + "/" + tests.length + " passed");
      return passed === tests.length;
    }
    return { it, expect, run };
  }

  // Functions under test
  const clamp = (value, min, max) => Math.min(Math.max(value, min), max);
  const slugify = text => text.toLowerCase().trim().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
  const parsePositive = input => {
    const number = Number(input);
    if (!Number.isFinite(number) || number <= 0) throw new RangeError("not a positive number");
    return number;
  };
  const fetchLater = async value => {
    await sleep(5);
    return value * 2;
  };

  const { it, expect, run } = createTestRunner();
  it("clamp keeps values inside the range", () => {
    expect(clamp(15, 0, 10)).toBe(10);
    expect(clamp(-1, 0, 10)).toBe(0);
    expect(clamp(5, 0, 10)).toBe(5);
  });
  it("slugify builds URL-friendly strings", () => {
    expect(slugify("  Hello, World!  ")).toBe("hello-world");
    expect(slugify("A  B   C")).toBe("a-b-c");
  });
  it("parsePositive rejects invalid input", () => {
    expect(() => parsePositive("abc")).toThrow(RangeError);
    expect(() => parsePositive(-4)).toThrow(RangeError);
    expect(parsePositive("12.5")).toBe(12.5);
  });
  it("async functions can be tested too", async () => {
    expect(await fetchLater(21)).toBe(42);
  });
  it("toEqual compares structure", () => {
    expect({ a: [1, 2], b: "x" }).toEqual({ a: [1, 2], b: "x" });
  });
  await run();
});

// ---------------------------------------------------------------------------
async function main() {
  let number = 0;
  for (const { title, body } of projects) {
    number += 1;
    console.log("\n[" + String(number).padStart(2, "0") + "] " + title);
    await body();
  }
  console.log("\nDone: " + number + " projects.");
}

main().catch(error => {
  console.error("Project failed:", error);
  process.exitCode = 1;
});
