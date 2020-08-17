type property = Location | Subgroup | About

let location : Localized_object.t =
  let labels =
    [|
      ("en", {js|Located in|js});
      ("fr", {js|Situé à|js})
    |] |> Js.Dict.fromArray
  in
  let descriptions =
    [|
      ("en", {js|A place where the group exists|js});
      ("fr", {js|Un lieu dans lequel existe le groupe|js})
    |] |> Js.Dict.fromArray
  in
  [%bs.obj {label = labels; description = descriptions}]

let subgroup : Localized_object.t =
  let labels =
    [|
      ("en", {js|Subgroup of|js});
      ("fr", {js|Sous-groupe de|js})
    |] |> Js.Dict.fromArray
  in
  let descriptions =
    [|
      ("en", {js|A parent group|js});
      ("fr", {js|Un groupe parent|js})
    |] |> Js.Dict.fromArray
  in
  [%bs.obj {label = labels; description = descriptions}]

let about : Localized_object.t =
  let labels =
    [|
      ("en", {js|About|js});
      ("fr", {js|À propos de|js})
    |] |> Js.Dict.fromArray
  in
  let descriptions =
    [|
      ("en", {js|A theme that the group is related|js});
      ("fr", {js|Un thème auquel le groupe est apparenté|js})
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
