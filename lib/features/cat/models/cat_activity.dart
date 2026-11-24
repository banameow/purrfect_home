/// What the cat is currently doing.
///
/// Phase 1 only needs idle/walking. Phase 2 adds sitting, sleeping, etc.
enum CatActivity {
  idle('Idle'),
  walking('Walking');

  const CatActivity(this.label);

  final String label;
}
