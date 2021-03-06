module State = struct
    type t =
      | Ready 			(* Service startup is finished *)
      | Reloading		(* Service is reloading its configuration. Has to send Ready when finished reloading *)
      | Stopping		(* Service is beginning to shutdown *)
      | Status of string	(* Passes a single UTF-8 status string *)
      | Error of Unix.error     (* Service failed with Unix Erro *)
      | Bus_error of string	(* Service failed with D-Bus error-style error code *)
      | Main_pid of int 	(* The main process ID *)
      | Watchdog		(* Update the watchdog timestamp *)
  end				(* FDSTORE not implemented yet *)

external caml_code_of_unix_error : Unix.error -> int = "caml_daemon_code_of_unix_error"
external caml_notify : bool -> string -> bool = "caml_daemon_notify"

let notify ?(unset_environment = false) state =
  let open State in
  let s = match state with
    | Ready -> "READY=1"
    | Reloading -> "RELOADING=1"
    | Stopping -> "STOPPING=1"
    | Status s -> "STATUS=" ^ s
    | Error u -> "ERRNO=" ^ (string_of_int (caml_code_of_unix_error u))
    | Bus_error s -> "BUSERROR=" ^ s
    | Main_pid i -> "MAINPID=" ^ (string_of_int i)
    | Watchdog -> "WATCHDOG=1"
  in caml_notify unset_environment s

external caml_listen_fds : bool -> Unix.file_descr list = "caml_daemon_listen_fds"

let listen_fds ?(unset_environment = true) () = caml_listen_fds unset_environment;

external booted : unit -> bool = "caml_daemon_booted"

