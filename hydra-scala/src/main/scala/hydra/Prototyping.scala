package hydra

import hydra.core.*;
import hydra.core.Variable


def atomicTypeAsTerm(at: AtomicType): Term = at match
  case AtomicType.binary() => unitVariant("binary")
  case AtomicType.boolean() => unitVariant("boolean")
  case AtomicType.float(ft) => variant("float", floatTypeAsTerm(ft))
  case AtomicType.integer(it) => variant("integer", integerTypeAsTerm(it))
  case AtomicType.string() => unitVariant("string")

def atomicTypeVariant(at: AtomicType): AtomicVariant = at match
  case AtomicType.binary() => AtomicVariant.boolean()
  case AtomicType.boolean() => AtomicVariant.boolean()
  case AtomicType.float(_) => AtomicVariant.float()
  case AtomicType.integer(_) => AtomicVariant.integer()
  case AtomicType.string() => AtomicVariant.string()

def atomicValueVariant(av: AtomicValue): AtomicVariant = av match
  case AtomicValue.binary(_) => AtomicVariant.binary()
  case AtomicValue.boolean(_) => AtomicVariant.boolean()
  case AtomicValue.float(_) => AtomicVariant.float()
  case AtomicValue.integer(_) => AtomicVariant.integer()
  case AtomicValue.string(_) => AtomicVariant.string()

def fieldTypeAsTerm(ft : FieldType): Term = Term.record(Seq(
  Field("name", string(ft.name)),
  Field("type", typeAsTerm(ft.`type`))))

def floatTypeAsTerm(ft: FloatType): Term = unitVariant(ft match
    case FloatType.bigfloat() => "bigfloat"
    case FloatType.float32() => "float32"
    case FloatType.float64() => "float64")

def floatTypeVariant(ft: FloatType): FloatVariant = ft match
  case FloatType.bigfloat() => FloatVariant.bigfloat()
  case FloatType.float32() => FloatVariant.float32()
  case FloatType.float64() => FloatVariant.float64()

def floatValueVariant(fv: FloatValue): FloatVariant = fv match
  case FloatValue.bigfloat(_) => FloatVariant.bigfloat()
  case FloatValue.float32(_) => FloatVariant.float32()
  case FloatValue.float64(_) => FloatVariant.float64()

def freeVariables(term: Term): Set[Variable] = {
  def free(bound: Set[Variable], t: Term): List[Variable] = term match
    case Term.application(Application(t1, t2)) => free(bound, t1) ++ free(bound, t2)
    case Term.atomic(_) => List()
    case Term.cases(CaseStatement(cases, dflt)) =>
      free(bound, dflt) ++ cases.flatMap(f => free(bound, f.term)).toList
    case Term.compareTo(t) => free(bound, t)
    case Term.data() => List()
    case Term.element(_) => List()
    case Term.function(_) => List()
    case Term.lambda(Lambda(v, t)) => free(bound + v, t)
    case Term.list(els) => els.flatMap(t => free(bound, t)).toList
    case Term.projection(_) => List()
    case Term.record(fields) => fields.flatMap(f => free(bound, f.term)).toList
    case Term.union(f) => free(bound, f.term)
    case Term.variable(v) => if bound.contains(v) then List() else List(v)

  free(Set(), term).toSet
}

def functionTypeAsTerm(ft: FunctionType): Term = Term.record(Seq(
  Field("domain", typeAsTerm(ft.domain)),
  Field("codomain", typeAsTerm(ft.codomain))))

def integerTypeAsTerm(it: IntegerType): Term = unitVariant(it match
  case IntegerType.bigint() => "bigint"
  case IntegerType.int8() => "int8"
  case IntegerType.int16() => "int16"
  case IntegerType.int32() => "int32"
  case IntegerType.int64() => "int64"
  case IntegerType.uint8() => "uint8"
  case IntegerType.uint16() => "uint16"
  case IntegerType.uint32() => "uint32"
  case IntegerType.uint64() => "uint64")

def integerTypeVariant(it: IntegerType): IntegerVariant = it match
  case IntegerType.bigint() => IntegerVariant.bigint()
  case IntegerType.int8() => IntegerVariant.int8()
  case IntegerType.int16() => IntegerVariant.int16()
  case IntegerType.int32() => IntegerVariant.int32()
  case IntegerType.int64() => IntegerVariant.int64()
  case IntegerType.uint8() => IntegerVariant.uint8()
  case IntegerType.uint16() => IntegerVariant.uint16()
  case IntegerType.uint32() => IntegerVariant.uint32()
  case IntegerType.uint64() => IntegerVariant.uint64()

def integerValueVariant(it: IntegerValue): IntegerVariant = it match
  case IntegerValue.bigint(_) => IntegerVariant.bigint()
  case IntegerValue.int8(_) => IntegerVariant.int8()
  case IntegerValue.int16(_) => IntegerVariant.int16()
  case IntegerValue.int32(_) => IntegerVariant.int32()
  case IntegerValue.int64(_) => IntegerVariant.int64()
  case IntegerValue.uint8(_) => IntegerVariant.uint8()
  case IntegerValue.uint16(_) => IntegerVariant.uint16()
  case IntegerValue.uint32(_) => IntegerVariant.uint32()
  case IntegerValue.uint64(_) => IntegerVariant.uint64()

def string(s: String): Term = Term.atomic(AtomicValue.string(s))

/**
 * Whether a term is closed, i.e. represents a complete program
 */
def termIsClosed(term : Term) : Boolean = freeVariables(term).isEmpty

def termVariant(term: Term): TermVariant = term match
  case Term.application(_) => TermVariant.application()
  case Term.atomic(_) => TermVariant.atomic()
  case Term.cases(_) => TermVariant.cases()
  case Term.compareTo(_) => TermVariant.compareTo()
  case Term.data() => TermVariant.data()
  case Term.element(_) => TermVariant.element()
  case Term.function(_) => TermVariant.function()
  case Term.lambda(_) => TermVariant.lambda()
  case Term.list(_) => TermVariant.list()
  case Term.projection(_) => TermVariant.projection()
  case Term.record(_) => TermVariant.record()
  case Term.union(_) => TermVariant.union()
  case Term.variable(_) => TermVariant.variable()

def typeAsTerm(typ: Type): Term = typ match
  case Type.atomic(at) => variant("atomic", atomicTypeAsTerm(at))
  case Type.element(t) => variant("element", typeAsTerm(t))
  case Type.function(ft) => variant("function", functionTypeAsTerm(ft))
  case Type.list(t) => variant("list", typeAsTerm(t))
  case Type.nominal(name) => variant("nominal", string(name))
  case Type.record(fields) => variant("record", Term.list(fields.map(fieldTypeAsTerm)))
  case Type.union(fields) => variant("union", Term.list(fields.map(fieldTypeAsTerm)))

def typeVariant(typ: Type): TypeVariant = typ match
  case Type.atomic(_) => TypeVariant.atomic()
  case Type.element(_) => TypeVariant.element()
  case Type.function(_) => TypeVariant.function()
  case Type.list(_) => TypeVariant.list()
  case Type.nominal(_) => TypeVariant.nominal()
  case Type.record(_) => TypeVariant.record()
  case Type.union(_) => TypeVariant.union()

val unitTerm: Term = Term.record(Seq())

def unitVariant(fname: FieldName): Term = variant(fname, unitTerm)

def variant(fname: FieldName, term: Term): Term = Term.union(Field(fname, term))
