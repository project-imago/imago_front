type property = Location | Subgroup | About

let location : Localized_object.t =
  let labels =
    [|
      ("en", "Located in");
      ("fr", "Situé à")
    |] |> Js.Dict.fromArray
  in
  let descriptions =
    [|
      ("en", "A place where the group exists");
      ("fr", "Un lieu dans lequel existe le groupe")
    |] |> Js.Dict.fromArray
  in
  [%bs.obj {label = labels; description = descriptions}]

let subgroup : Localized_object.t =
  let labels =
    [|
      ("en", "Subgroup of");
      ("fr", "Sous-groupe de")
    |] |> Js.Dict.fromArray
  in
  let descriptions =
    [|
      ("en", "A parent group");
      ("fr", "Un groupe parent")
    |] |> Js.Dict.fromArray
  in
  [%bs.obj {label = labels; description = descriptions}]

let about : Localized_object.t =
  let labels =
    [|
      ("en", "About");
      ("fr", "À propos de")
    |] |> Js.Dict.fromArray
  in
  let descriptions =
    [|
      ("en", "A theme that the group is related");
      ("fr", "Un thème auquel le groupe est apparenté")
    |] |> Js.Dict.fromArray
  in
  [%bs.obj {label = labels; description = descriptions}]

let properties =
  [|
    ("http://imago.pm/property/location", location);
    ("http://imago.pm/property/subgroup", subgroup);
    ("http://imago.pm/property/about",    about);
  |] |> Js.Dict.fromArray

let localized_properties lc =
  [|
    Labeled_statements.from_localized_object "http://imago.pm/property/location"
    location lc;
    Labeled_statements.from_localized_object "http://imago.pm/property/subgroup"
    subgroup lc;
    Labeled_statements.from_localized_object "http://imago.pm/property/about"
    about lc;
  |]

let variant_of_iri = function
  | "http://imago.pm/property/location" -> Location
  | "http://imago.pm/property/subgroup" -> Subgroup
  | "http://imago.pm/property/about" -> About
  | _ -> Location
