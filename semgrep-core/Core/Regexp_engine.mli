
module Str_engine : sig
  type t = string * Str.regexp
  val show: t -> string

  val regexp: string -> t
  val matching_exact_string: string -> t

  val run: t -> string -> bool
end

module Pcre_engine : sig
  type t = string * Pcre.regexp
  val show: t -> string
  val equal: t -> t -> bool
  val pp: Format.formatter -> t -> unit

  val matching_exact_string: string -> t

  val run: t -> string -> bool

end

module Re_engine: sig
  type t = string * Re.t
  val show: t -> string

  val matching_exact_string: string -> t

  val run: t -> string -> bool
end
