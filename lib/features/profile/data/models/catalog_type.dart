/// Enum identifying which medical catalog a selection sheet is editing.
///
/// Used by [CatalogSelectionSheet] to know which `create*` endpoint to
/// call when the user adds a custom item.
enum CatalogType { allergy, disease, history }
