"use strict";

/*
 * JavaScript Functions - Part 3: Advanced
 *
 * Run:   node 03-advanced.js
 * Needs: Node.js 16 or newer, no dependencies.
 *
 * Topics: currying, partial application, composition, memoization, debounce and
 * throttle, decorators, trampolines, Proxy, middleware, event emitters, state
 * machines, Promises, async/await patterns, cancellation, concurrency limits,
 * generators, lazy pipelines, custom iterables.
 *
 * Examples run one after another (some are asynchronous), so the output order
 * always matches the order in this file.
 */

const examples = [];
function demo(title, body) {
  examples.push({ title, body });
}

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

// ===========================================================================
// A. Functional building blocks
// ===========================================================================

demo("Generic curry", () => {
  function curry(fn) {
    return function curried(...args) {
      if (args.length >= fn.length) return fn.apply(this, args);
      return (...more) => curried.apply(this, [...args, ...more]);
    };
  }
  const volume = curry((length, width, height) => length * width * height);
  console.log(volume(2)(3)(4));  // 24
  console.log(volume(2, 3)(4));  // 24
  console.log(volume(2)(3, 4));  // 24
  const withBase = volume(10, 10);
  console.log([1, 2, 3].map(withBase)); // [ 100, 200, 300 ]
});

demo("Partial application", () => {
  const partial = (fn, ...preset) => (...later) => fn(...preset, ...later);
  const partialRight = (fn, ...preset) => (...later) => fn(...later, ...preset);
  const request = (method, url, body) => method + " " + url + (body ? " " + JSON.stringify(body) : "");
  const get = partial(request, "GET");
  const postToUsers = partial(request, "POST", "/users");
  const withoutBody = partialRight(request, undefined);
  console.log(get("/health"));
  console.log(postToUsers({ name: "Sara" }));
  console.log(withoutBody("DELETE", "/users/7"));
});

demo("compose and pipe", () => {
  const compose = (...fns) => input => fns.reduceRight((acc, fn) => fn(acc), input);
  const pipe = (...fns) => input => fns.reduce((acc, fn) => fn(acc), input);

  const trim = s => s.trim();
  const upper = s => s.toUpperCase();
  const exclaim = s => s + "!";
  const words = s => s.split(/\s+/);

  console.log(pipe(trim, upper, exclaim)("  hello  "));    // HELLO!
  console.log(compose(exclaim, upper, trim)("  hello  "));  // HELLO!  (same, reversed order)
  console.log(pipe(trim, words)("  one two three "));      // [ 'one', 'two', 'three' ]
});

demo("pipe for async steps", async () => {
  const pipeAsync = (...fns) => input => fns.reduce((acc, fn) => acc.then(fn), Promise.resolve(input));
  const fetchUser = async id => ({ id, name: "user" + id });
  const addRole = async user => ({ ...user, role: "member" });
  const format = user => user.name + " (" + user.role + ")";
  console.log(await pipeAsync(fetchUser, addRole, format)(7)); // user7 (member)
});

demo("Memoize with a custom key", () => {
  function memoize(fn, resolver = (...args) => JSON.stringify(args)) {
    const cache = new Map();
    const memoized = function (...args) {
      const key = resolver(...args);
      if (cache.has(key)) {
        memoized.hits += 1;
        return cache.get(key);
      }
      memoized.misses += 1;
      const result = fn.apply(this, args);
      cache.set(key, result);
      return result;
    };
    memoized.hits = 0;
    memoized.misses = 0;
    memoized.clear = () => cache.clear();
    return memoized;
  }

  let realCalls = 0;
  const slowAdd = memoize((a, b) => {
    realCalls += 1;
    return a + b;
  });
  console.log(slowAdd(1, 2), slowAdd(1, 2), slowAdd(2, 1));
  console.log("real calls:", realCalls, "hits:", slowAdd.hits, "misses:", slowAdd.misses);

  const fib = memoize(n => (n < 2 ? n : fib(n - 1) + fib(n - 2)));
  console.log(fib(60)); // 1548008755920
});

demo("once, before and after", () => {
  const once = fn => {
    let called = false;
    let result;
    return function (...args) {
      if (!called) {
        called = true;
        result = fn.apply(this, args);
      }
      return result;
    };
  };
  const before = (limit, fn) => {
    let count = 0;
    let last;
    return (...args) => (count++ < limit ? (last = fn(...args)) : last);
  };
  const after = (limit, fn) => {
    let count = 0;
    return (...args) => (++count >= limit ? fn(...args) : undefined);
  };

  const init = once(() => {
    console.log("initializing...");
    return "ready";
  });
  console.log(init(), init(), init());

  const firstTwo = before(2, n => n * 10);
  console.log(firstTwo(1), firstTwo(2), firstTwo(3), firstTwo(4)); // 10 20 20 20

  const fromThird = after(3, () => "go");
  console.log(fromThird(), fromThird(), fromThird()); // undefined undefined go
});

demo("Small utilities: flip, tap, unary, constant", () => {
  const flip = fn => (a, b, ...rest) => fn(b, a, ...rest);
  const tap = fn => value => {
    fn(value);
    return value;
  };
  const unary = fn => a => fn(a);
  const constant = value => () => value;

  console.log(flip((a, b) => a + "-" + b)("left", "right")); // right-left
  console.log(["1", "2", "3"].map(unary(parseInt)));          // [ 1, 2, 3 ]
  const result = [3, 1, 2]
    .map(tap(n => console.log("seen", n)))
    .sort((a, b) => a - b);
  console.log(result);
  console.log(Array.from({ length: 3 }, constant("x"))); // [ 'x', 'x', 'x' ]
});

demo("Decorators: logging, timing, argument validation", () => {
  const logCalls = (fn, label = fn.name) => (...args) => {
    const result = fn(...args);
    console.log(label + "(" + args.join(", ") + ") -> " + result);
    return result;
  };
  const timeIt = fn => (...args) => {
    const start = process.hrtime.bigint();
    const result = fn(...args);
    const ms = Number(process.hrtime.bigint() - start) / 1e6;
    return { result, ms };
  };
  const requireNumbers = fn => (...args) => {
    args.forEach((value, index) => {
      if (typeof value !== "number" || Number.isNaN(value)) {
        throw new TypeError("Argument " + index + " must be a number");
      }
    });
    return fn(...args);
  };

  function multiply(a, b) {
    return a * b;
  }
  const safeMultiply = logCalls(requireNumbers(multiply), "multiply");
  safeMultiply(6, 7);
  try {
    safeMultiply(6, "7");
  } catch (error) {
    console.log("rejected:", error.message);
  }
  const timed = timeIt(n => {
    let sum = 0;
    for (let i = 0; i < n; i++) sum += i;
    return sum;
  })(1e6);
  console.log("result:", timed.result, "| measured:", timed.ms >= 0);
});

demo("Trampoline: deep recursion without stack overflow", () => {
  const trampoline = fn => (...args) => {
    let result = fn(...args);
    while (typeof result === "function") result = result();
    return result;
  };
  const sumTo = trampoline(function go(n, acc = 0) {
    return n === 0 ? acc : () => go(n - 1, acc + n);
  });
  console.log(sumTo(1000000)); // 500000500000
});

demo("Tagged template functions", () => {
  function highlight(strings, ...values) {
    return strings.reduce(
      (out, text, i) => out + text + (i < values.length ? "[" + values[i] + "]" : ""),
      ""
    );
  }
  function sql(strings, ...values) {
    return { text: strings.join("?"), params: values };
  }
  const name = "Sara";
  const age = 30;
  console.log(highlight`Name: ${name}, age: ${age}`);
  console.log(sql`SELECT * FROM users WHERE name = ${name} AND age > ${age}`);
});

demo("Proxy around a function (apply trap)", () => {
  function withCallCount(fn) {
    let calls = 0;
    return new Proxy(fn, {
      apply(target, thisArg, args) {
        calls += 1;
        return Reflect.apply(target, thisArg, args);
      },
      get(target, prop, receiver) {
        if (prop === "calls") return calls;
        return Reflect.get(target, prop, receiver);
      },
    });
  }
  const square = withCallCount(n => n * n);
  square(2);
  square(3);
  square(4);
  console.log("calls:", square.calls); // 3
});

demo("Functions are objects: custom properties", () => {
  function visit() {
    visit.count += 1;
    return visit.count;
  }
  visit.count = 0;
  visit();
  visit();
  console.log(visit.count);                  // 2
  console.log(typeof visit, visit instanceof Object); // function true
});

demo("Composable validators", () => {
  const rule = (test, message) => value => (test(value) ? null : message);
  const validate = (...rules) => value => rules.map(r => r(value)).filter(Boolean);

  const validatePassword = validate(
    rule(v => v.length >= 8, "at least 8 characters"),
    rule(v => /[A-Z]/.test(v), "an uppercase letter"),
    rule(v => /[0-9]/.test(v), "a digit")
  );
  console.log(validatePassword("abc"));          // 3 problems
  console.log(validatePassword("Abcdefgh1"));    // []
});

demo("Immutable updates with a small helper", () => {
  const setIn = (obj, [key, ...rest], value) =>
    rest.length === 0
      ? { ...obj, [key]: value }
      : { ...obj, [key]: setIn(obj[key] ?? {}, rest, value) };

  const state = { user: { name: "Sara", address: { city: "Berlin" } }, settings: { theme: "dark" } };
  const next = setIn(state, ["user", "address", "city"], "Munich");
  console.log(state.user.address.city, "->", next.user.address.city);
  console.log("settings shared:", state.settings === next.settings); // true
  console.log("user replaced:", state.user !== next.user);           // true
});

// ===========================================================================
// B. Timing: debounce and throttle
// ===========================================================================

demo("Debounce", async () => {
  function debounce(fn, wait) {
    let timer;
    const debounced = function (...args) {
      clearTimeout(timer);
      timer = setTimeout(() => fn.apply(this, args), wait);
    };
    debounced.cancel = () => clearTimeout(timer);
    return debounced;
  }
  const search = debounce(query => console.log("search for:", query), 30);
  search("j");
  search("ja");
  search("jav");
  await sleep(80); // only the last call runs
  const cancelled = debounce(() => console.log("never printed"), 30);
  cancelled();
  cancelled.cancel();
  await sleep(60);
  console.log("done");
});

demo("Throttle", async () => {
  function throttle(fn, interval) {
    let last = -Infinity;
    return function (...args) {
      const now = Date.now();
      if (now - last >= interval) {
        last = now;
        return fn.apply(this, args);
      }
    };
  }
  let runs = 0;
  const onScroll = throttle(() => {
    runs += 1;
  }, 50);
  for (let i = 0; i < 10; i++) onScroll(); // burst: only the first call runs
  console.log("after burst:", runs);        // 1
  await sleep(70);
  onScroll();
  console.log("after waiting:", runs);      // 2
});

// ===========================================================================
// C. Design patterns built from functions
// ===========================================================================

demo("Event emitter from closures", () => {
  function createEmitter() {
    const handlers = new Map();
    return {
      on(event, handler) {
        if (!handlers.has(event)) handlers.set(event, new Set());
        handlers.get(event).add(handler);
        return () => handlers.get(event).delete(handler); // unsubscribe function
      },
      once(event, handler) {
        const off = this.on(event, (...args) => {
          off();
          handler(...args);
        });
        return off;
      },
      emit(event, ...args) {
        (handlers.get(event) || []).forEach(handler => handler(...args));
      },
    };
  }
  const emitter = createEmitter();
  const off = emitter.on("greet", name => console.log("hello", name));
  emitter.once("greet", name => console.log("first greeting only:", name));
  emitter.emit("greet", "Sara");
  emitter.emit("greet", "Ali");
  off();
  emitter.emit("greet", "nobody sees this");
});

demo("Middleware pipeline (Koa style)", async () => {
  function createPipeline() {
    const stack = [];
    return {
      use(fn) {
        stack.push(fn);
        return this;
      },
      run(context) {
        let index = -1;
        const dispatch = i => {
          if (i <= index) return Promise.reject(new Error("next() called twice"));
          index = i;
          const fn = stack[i];
          if (!fn) return Promise.resolve();
          return Promise.resolve(fn(context, () => dispatch(i + 1)));
        };
        return dispatch(0);
      },
    };
  }
  const app = createPipeline()
    .use(async (ctx, next) => {
      ctx.trace.push("logger:before");
      await next();
      ctx.trace.push("logger:after");
    })
    .use(async (ctx, next) => {
      ctx.trace.push("auth");
      await next();
    })
    .use(async ctx => {
      ctx.trace.push("handler");
      ctx.body = "OK";
    });
  const ctx = { trace: [] };
  await app.run(ctx);
  console.log(ctx.trace.join(" > "));
  console.log("body:", ctx.body);
});

demo("State machine with a transition table", () => {
  const transitions = {
    idle: { start: "running" },
    running: { pause: "paused", stop: "idle" },
    paused: { resume: "running", stop: "idle" },
  };
  function createMachine(initial) {
    let state = initial;
    return {
      send(action) {
        const next = transitions[state][action];
        if (!next) throw new Error("Invalid action '" + action + "' in state '" + state + "'");
        state = next;
        return state;
      },
      get state() {
        return state;
      },
    };
  }
  const machine = createMachine("idle");
  console.log(machine.send("start"), machine.send("pause"), machine.send("resume"), machine.send("stop"));
  try {
    machine.send("pause");
  } catch (error) {
    console.log(error.message);
  }
});

// ===========================================================================
// D. Asynchronous functions
// ===========================================================================

demo("promisify an error-first callback function", async () => {
  const promisify = fn => (...args) =>
    new Promise((resolve, reject) => {
      fn(...args, (error, value) => (error ? reject(error) : resolve(value)));
    });
  function legacyDouble(n, callback) {
    setTimeout(() => (n < 0 ? callback(new Error("negative input")) : callback(null, n * 2)), 5);
  }
  const doubleAsync = promisify(legacyDouble);
  console.log(await doubleAsync(21)); // 42
  try {
    await doubleAsync(-1);
  } catch (error) {
    console.log("rejected:", error.message);
  }
});

demo("Promise chain: then, catch, finally", async () => {
  await sleep(5)
    .then(() => {
      console.log("step 1");
      return 10;
    })
    .then(value => {
      console.log("step 2 got", value);
      throw new Error("something failed");
    })
    .then(() => console.log("skipped"))
    .catch(error => {
      console.log("caught:", error.message);
      return "recovered";
    })
    .then(value => console.log("after catch:", value))
    .finally(() => console.log("finally runs always"));
});

demo("Sequential vs parallel await", async () => {
  const task = async (name, ms) => {
    await sleep(ms);
    return name;
  };
  let start = Date.now();
  const sequential = [];
  sequential.push(await task("a", 30));
  sequential.push(await task("b", 30));
  sequential.push(await task("c", 30));
  const sequentialMs = Date.now() - start;

  start = Date.now();
  const parallel = await Promise.all([task("a", 30), task("b", 30), task("c", 30)]);
  const parallelMs = Date.now() - start;

  console.log(sequential, parallel);
  console.log("parallel is faster:", parallelMs < sequentialMs); // true
});

demo("Promise.all, allSettled, race, any", async () => {
  const ok = (value, ms) => sleep(ms).then(() => value);
  const fail = (message, ms) => sleep(ms).then(() => Promise.reject(new Error(message)));

  console.log(await Promise.all([ok("a", 10), ok("b", 5)]));
  const settled = await Promise.allSettled([ok("fine", 5), fail("broken", 5)]);
  console.log(settled.map(r => r.status + ":" + (r.value || r.reason.message)));
  console.log(await Promise.race([ok("slow", 30), ok("fast", 5)]));
  console.log(await Promise.any([fail("e1", 5), ok("winner", 15), fail("e2", 8)]));
  try {
    await Promise.all([ok("a", 5), fail("first failure", 10)]);
  } catch (error) {
    console.log("Promise.all rejected with:", error.message);
  }
});

demo("Timeout wrapper with Promise.race", async () => {
  function withTimeout(promise, ms) {
    let timer;
    const timeout = new Promise((_, reject) => {
      timer = setTimeout(() => reject(new Error("Timed out after " + ms + " ms")), ms);
    });
    return Promise.race([promise, timeout]).finally(() => clearTimeout(timer));
  }
  console.log(await withTimeout(sleep(10).then(() => "finished in time"), 100));
  try {
    await withTimeout(sleep(100), 20);
  } catch (error) {
    console.log(error.message);
  }
});

demo("Retry with exponential backoff", async () => {
  async function retry(task, { retries = 3, delay = 10, factor = 2 } = {}) {
    let attempt = 0;
    let wait = delay;
    for (;;) {
      try {
        return await task(attempt);
      } catch (error) {
        if (attempt >= retries) throw error;
        console.log("attempt " + (attempt + 1) + " failed: " + error.message + " (waiting " + wait + " ms)");
        attempt += 1;
        await sleep(wait);
        wait *= factor;
      }
    }
  }
  const flaky = async attempt => {
    if (attempt < 2) throw new Error("temporary failure");
    return "succeeded on attempt " + (attempt + 1);
  };
  console.log(await retry(flaky));
  try {
    await retry(async () => {
      throw new Error("permanent failure");
    }, { retries: 1, delay: 5 });
  } catch (error) {
    console.log("gave up:", error.message);
  }
});

demo("Run async work with a concurrency limit", async () => {
  async function mapLimit(items, limit, worker) {
    const results = new Array(items.length);
    let next = 0;
    let active = 0;
    let maxActive = 0;
    async function run() {
      while (next < items.length) {
        const index = next++;
        active += 1;
        maxActive = Math.max(maxActive, active);
        try {
          results[index] = await worker(items[index], index);
        } finally {
          active -= 1;
        }
      }
    }
    await Promise.all(Array.from({ length: Math.min(limit, items.length) }, run));
    return { results, maxActive };
  }
  const { results, maxActive } = await mapLimit([1, 2, 3, 4, 5, 6, 7, 8], 3, async n => {
    await sleep(10);
    return n * n;
  });
  console.log(results.join(" "));  // 1 4 9 16 25 36 49 64
  console.log("max concurrent:", maxActive); // 3
});

demo("Microtasks run before timers", async () => {
  const log = [];
  setTimeout(() => log.push("timeout"), 0);
  Promise.resolve().then(() => log.push("promise"));
  queueMicrotask(() => log.push("microtask"));
  log.push("sync");
  await sleep(10);
  console.log(log.join(" > ")); // sync > promise > microtask > timeout
});

demo("Cancel work with AbortController", async () => {
  function abortableSleep(ms, signal) {
    return new Promise((resolve, reject) => {
      const timer = setTimeout(resolve, ms);
      signal.addEventListener(
        "abort",
        () => {
          clearTimeout(timer);
          reject(new Error("aborted"));
        },
        { once: true }
      );
    });
  }
  const controller = new AbortController();
  const work = abortableSleep(1000, controller.signal);
  setTimeout(() => controller.abort(), 10);
  try {
    await work;
  } catch (error) {
    console.log("work was", error.message);
  }
});

demo("Share one in-flight request (async memoize)", async () => {
  function memoizeAsync(fn) {
    const cache = new Map();
    return key => {
      if (!cache.has(key)) {
        const promise = fn(key).catch(error => {
          cache.delete(key); // do not cache failures
          throw error;
        });
        cache.set(key, promise);
      }
      return cache.get(key);
    };
  }
  let networkCalls = 0;
  const fetchUser = async id => {
    networkCalls += 1;
    await sleep(10);
    return { id, name: "user" + id };
  };
  const cachedFetch = memoizeAsync(fetchUser);
  const [a, b, c] = await Promise.all([cachedFetch(1), cachedFetch(1), cachedFetch(1)]);
  console.log(a === b && b === c, "network calls:", networkCalls); // true network calls: 1
});

demo("Serial task queue", async () => {
  function createQueue() {
    let tail = Promise.resolve();
    return task => {
      const result = tail.then(task);
      tail = result.catch(() => {}); // a failure must not block the queue
      return result;
    };
  }
  const enqueue = createQueue();
  const order = [];
  const job = (name, ms, shouldFail = false) => async () => {
    await sleep(ms);
    order.push(name);
    if (shouldFail) throw new Error(name + " failed");
    return name;
  };
  const results = await Promise.allSettled([
    enqueue(job("first", 30)),
    enqueue(job("second", 5, true)),
    enqueue(job("third", 1)),
  ]);
  console.log(order.join(" > "));                         // first > second > third
  console.log(results.map(r => r.status).join(", "));     // fulfilled, rejected, fulfilled
});

demo("Async generator and for await", async () => {
  async function* ticker(count, ms) {
    for (let i = 1; i <= count; i++) {
      await sleep(ms);
      yield i;
    }
  }
  for await (const tick of ticker(3, 5)) {
    console.log("tick", tick);
  }
});

// ===========================================================================
// E. Generators and iterators
// ===========================================================================

demo("Generator basics and two-way communication", () => {
  function* countTo(limit) {
    for (let i = 1; i <= limit; i++) yield i;
    return "finished";
  }
  const it = countTo(2);
  console.log(it.next(), it.next(), it.next());
  console.log([...countTo(4)]); // return value is not part of the spread

  function* accumulator() {
    let total = 0;
    for (;;) {
      const value = yield total;
      if (value === undefined) return total;
      total += value;
    }
  }
  const acc = accumulator();
  acc.next();                  // start: runs to the first yield
  console.log(acc.next(5).value);   // 5
  console.log(acc.next(10).value);  // 15
  console.log(acc.next());          // { value: 15, done: true }
});

demo("Lazy pipelines over an infinite sequence", () => {
  function* naturals() {
    let n = 1;
    for (;;) yield n++;
  }
  function* map(iterable, fn) {
    for (const item of iterable) yield fn(item);
  }
  function* filter(iterable, predicate) {
    for (const item of iterable) if (predicate(item)) yield item;
  }
  function* take(iterable, count) {
    if (count <= 0) return;
    let taken = 0;
    for (const item of iterable) {
      yield item;
      if (++taken >= count) return;
    }
  }
  const oddSquares = take(filter(map(naturals(), n => n * n), n => n % 2 === 1), 5);
  console.log([...oddSquares]); // [ 1, 9, 25, 49, 81 ]
});

demo("Infinite Fibonacci and a custom iterable", () => {
  function* fibonacci() {
    let [a, b] = [0, 1];
    for (;;) {
      yield a;
      [a, b] = [b, a + b];
    }
  }
  const first = [];
  for (const value of fibonacci()) {
    if (first.length === 10) break;
    first.push(value);
  }
  console.log(first.join(" ")); // 0 1 1 2 3 5 8 13 21 34

  class Range {
    constructor(start, end, step = 1) {
      Object.assign(this, { start, end, step });
    }
    *[Symbol.iterator]() {
      for (let value = this.start; value <= this.end; value += this.step) yield value;
    }
  }
  console.log([...new Range(1, 10, 3)]);       // [ 1, 4, 7, 10 ]
  console.log(Math.max(...new Range(0, 50, 5))); // 50
});

// ===========================================================================
// Runner
// ===========================================================================

async function main() {
  let number = 0;
  for (const { title, body } of examples) {
    number += 1;
    console.log("\n[" + String(number).padStart(2, "0") + "] " + title);
    await body();
  }
  console.log("\nDone: " + number + " examples.");
}

main().catch(error => {
  console.error("Example failed:", error);
  process.exitCode = 1;
});
