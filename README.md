# HDL Floating-Point Units (IEEE 754)

A collection of IEEE 754 compliant floating-point units written in Verilog.  
Supports **half (binary16), single (binary32), and double (binary64)** precision formats, with core arithmetic operations, converters, comparators, and advanced functions.

---

## 📌 Features

- **Core Arithmetic**
  - Floating-point addition, subtraction, multiplication, division
- **Converters**
  - Integer ↔ Floating-point
  - Cross-precision: half ↔ single, single ↔ double
- **Comparators**
  - Equal, less-than, less-or-equal (IEEE 754 rules)
- **Special Value Handling**
  - NaN, Infinity, Zero, Denormal numbers
- **Rounding Modes**
  - Round to nearest even (default)
  - Toward 0
  - Toward +∞
  - Toward -∞
- **Exceptions**
  - Overflow, underflow, inexact, invalid operation
- **Advanced Operations (WIP)**
  - Square root
  - Reciprocal
  - Fused Multiply-Add (FMA)
- **Unified FPU Top**
  - Multi-operation unit with clean interface


---

## 📂 Repository Structure

hdl-floatingpoint/
├── README.md
├── docs/ # Documentation and diagrams
│ ├── ieee754_summary.md
│ ├── rounding_modes.md
│ └── exceptions.md
├── src/ # RTL source code
│ ├── common/ # Shared blocks (shifters, LZD, normalizers, rounding)
│ ├── half/ # FP16 (binary16) units
│ ├── single/ # FP32 (binary32) units
│ ├── double/ # FP64 (binary64) units
│ ├── converters/ # Int ↔ FP, FP ↔ FP
│ ├── comparators/ # eq, lt, le, etc.
│ ├── special/ # NaN/Inf/Zero/Denorm detection
│ ├── advanced/ # sqrt, reciprocal, FMA
│ └── top/ # Unified fpu_top.v
├── tb/ # Testbenches
└── results/ # Waveforms, synthesis reports


---

## 🚀 Roadmap

### Phase 1 – Core Operations
- [x] FP16 adder, multiplier, divider  
- [x] Shared modules (normalizer, shifters, LZD)  
- [ ] Basic testbenches  

### Phase 2 – Usability Extensions
- [ ] Int ↔ FP16 converters  
- [ ] FP16 ↔ FP32 converters  
- [ ] Comparators (eq, lt, le)  
- [ ] Special value detection  
- [ ] Full rounding modes  

### Phase 3 – Higher Precision & Exceptions
- [ ] FP32 adder, multiplier, divider  
- [ ] FP64 adder, multiplier  
- [ ] Exception flags (overflow, underflow, invalid, inexact)  
- [ ] Randomized testbenches (Python golden model)  

### Phase 4 – Advanced Ops
- [ ] FP sqrt, reciprocal  
- [ ] Fused multiply-add (FMA)  
- [ ] Unified `fpu_top.v`  

### Phase 5 – Bonus
- [ ] Mixed-precision support (FP16 compute + FP32 accumulate)  
- [ ] Parameterized mantissa/exponent generator  
- [ ] Integration with RISC-V CPU repo  

---

## 🧪 Testing

- **Directed tests:** simple known values (1.5+2.5, Inf+1, NaN*0, etc.)  
- **Randomized tests:** Python-based test generator (`scripts/test_vectors.py`)  
- **Reference models:** Python `numpy.float16/32/64`, `decimal` library  

---

## 📊 Results

- **Waveform screenshots** in `results/waveforms/`
- **Synthesis reports** in `results/synthesis/`