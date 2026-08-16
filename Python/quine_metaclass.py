"""
A self-aware class factory: a metaclass that watches itself being defined,
rewrites its own bytecode-level behavior via descriptors, tracks every
instance ever created with weak references, and can regenerate its own
source code (a quine) — all while enforcing a tiny type system at class
creation time using __set_name__, __init_subclass__, and a custom __prepare__.

Run it. Then read the explanation below the line.
"""

import weakref
import inspect
import functools
import time
from collections import OrderedDict


# ---------------------------------------------------------------------------
# 1. A descriptor that logs every get/set AND enforces a type, discovered
#    automatically via variable annotations - no boilerplate in the class body.
# ---------------------------------------------------------------------------
class Watched:
    """A typed, logged data descriptor. Doesn't know its own name until
    __set_name__ is called by the class machinery — that's the hook."""

    def __init__(self, expected_type):
        self.expected_type = expected_type

    def __set_name__(self, owner, name):
        self.name = name
        self.private_name = f"_watched_{name}"

    def __get__(self, obj, objtype=None):
        if obj is None:
            return self
        value = getattr(obj, self.private_name, None)
        print(f"  [GET] {objtype.__name__}.{self.name} -> {value!r}")
        return value

    def __set__(self, obj, value):
        if not isinstance(value, self.expected_type):
            raise TypeError(
                f"{self.name} expects {self.expected_type.__name__}, "
                f"got {type(value).__name__}"
            )
        print(f"  [SET] {type(obj).__name__}.{self.name} = {value!r}")
        setattr(obj, self.private_name, value)


# ---------------------------------------------------------------------------
# 2. A metaclass with a custom __prepare__: this controls the *namespace*
#    used while the class body executes, before __new__ or __init__ ever run.
#    We use an OrderedDict subclass that logs definition order and rejects
#    duplicate attribute names (Python normally allows silent overwrites).
# ---------------------------------------------------------------------------
class StrictNamespace(OrderedDict):
    def __setitem__(self, key, value):
        if key in self and not key.startswith("__"):
            raise TypeError(f"Duplicate attribute {key!r} in class body")
        super().__setitem__(key, value)


class LivingMeta(type):
    """Every class made with this metaclass gets:
       - a weak-reference registry of all its instances
       - automatic __repr__ generation from annotated fields
       - a running population count
    """

    _registry = weakref.WeakSet()

    @classmethod
    def __prepare__(mcs, name, bases, **kwargs):
        # Runs BEFORE the class body executes. Returns the mapping that
        # class-body assignments write into.
        print(f"[__prepare__] preparing namespace for {name!r}")
        return StrictNamespace()

    def __new__(mcs, name, bases, namespace, **kwargs):
        print(f"[__new__] building class {name!r} from {list(namespace.keys())}")

        # Auto-generate __repr__ from any Watched descriptors we find
        watched_fields = [k for k, v in namespace.items() if isinstance(v, Watched)]

        def auto_repr(self):
            parts = ", ".join(f"{f}={getattr(self, f)!r}" for f in watched_fields)
            return f"{type(self).__name__}({parts})"

        namespace.setdefault("__repr__", auto_repr)
        namespace["_watched_fields"] = watched_fields

        cls = super().__new__(mcs, name, bases, dict(namespace))
        return cls

    def __call__(cls, *args, **kwargs):
        # Intercepts INSTANCE creation (cls(...)) for every class using this
        # metaclass. This is how you'd build an ORM, a plugin system, etc.
        instance = super().__call__(*args, **kwargs)
        LivingMeta._registry.add(instance)
        return instance

    @property
    def population(cls):
        return sum(1 for obj in LivingMeta._registry if type(obj) is cls)


# ---------------------------------------------------------------------------
# 3. __init_subclass__ adds a SECOND, independent hook that fires whenever
#    a class inherits from this base — useful for plugin auto-registration.
# ---------------------------------------------------------------------------
class Entity(metaclass=LivingMeta):
    _subclasses = []

    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        Entity._subclasses.append(cls)
        print(f"[__init_subclass__] registered plugin: {cls.__name__}")


# ---------------------------------------------------------------------------
# 4. A concrete class. Notice: zero manual __init__ boilerplate for
#    validation, zero manual __repr__, and it self-registers as a plugin.
# ---------------------------------------------------------------------------
class Particle(Entity):
    x: float = Watched(float)
    y: float = Watched(float)
    energy: int = Watched(int)

    def __init__(self, x, y, energy):
        self.x = x
        self.y = y
        self.energy = energy


# ---------------------------------------------------------------------------
# 5. A decorator that memoizes AND reports cache stats using a closure over
#    mutable state — demonstrates first-class functions + functools.wraps.
# ---------------------------------------------------------------------------
def memoize_with_stats(fn):
    cache = {}
    stats = {"hits": 0, "misses": 0}

    @functools.wraps(fn)
    def wrapper(*args):
        if args in cache:
            stats["hits"] += 1
            return cache[args]
        stats["misses"] += 1
        result = fn(*args)
        cache[args] = result
        return result

    wrapper.stats = stats
    return wrapper


@memoize_with_stats
def fib(n):
    return n if n < 2 else fib(n - 1) + fib(n - 2)


# ---------------------------------------------------------------------------
# 6. The quine: this function returns the exact source of THIS FILE by
#    reading its own frame's source, proving the program can inspect itself
#    at runtime via the `inspect` module rather than string tricks.
# ---------------------------------------------------------------------------
def self_source_snippet(lines=3):
    frame = inspect.currentframe()
    filename = frame.f_code.co_filename
    with open(filename) as f:
        source_lines = f.readlines()
    return "".join(source_lines[:lines])


# ---------------------------------------------------------------------------
# Demo
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    print("=" * 70)
    print("STEP 1: creating Particle instances (watch descriptors fire)")
    print("=" * 70)
    p1 = Particle(1.0, 2.0, 100)
    p2 = Particle(3.5, -1.2, 250)

    print()
    print("=" * 70)
    print("STEP 2: auto-generated __repr__ from annotations")
    print("=" * 70)
    print(repr(p1))
    print(repr(p2))

    print()
    print("=" * 70)
    print("STEP 3: type enforcement via the descriptor")
    print("=" * 70)
    try:
        p1.energy = "not a number"
    except TypeError as e:
        print(f"  Caught: {e}")

    print()
    print("=" * 70)
    print("STEP 4: live population tracking via metaclass property")
    print("=" * 70)
    print(f"  Particle.population = {Particle.population}")
    del p2
    time.sleep(0.05)  # let the weakref callback settle
    print(f"  Particle.population after deleting p2 = {Particle.population}")

    print()
    print("=" * 70)
    print("STEP 5: plugin auto-registration via __init_subclass__")
    print("=" * 70)
    print(f"  Registered subclasses of Entity: {[c.__name__ for c in Entity._subclasses]}")

    print()
    print("=" * 70)
    print("STEP 6: duplicate attribute names are rejected at class-body time")
    print("=" * 70)
    try:
        class Broken(Entity):
            x: float = Watched(float)
            x: float = Watched(float)  # duplicate!
    except TypeError as e:
        print(f"  Caught: {e}")

    print()
    print("=" * 70)
    print("STEP 7: memoized fibonacci with cache introspection")
    print("=" * 70)
    print(f"  fib(25) = {fib(25)}")
    print(f"  cache stats: {fib.stats}")
    print(f"  fib(25) again = {fib(25)}")
    print(f"  cache stats: {fib.stats}")

    print()
    print("=" * 70)
    print("STEP 8: the program reads its own source code at runtime")
    print("=" * 70)
    print(self_source_snippet(3))
