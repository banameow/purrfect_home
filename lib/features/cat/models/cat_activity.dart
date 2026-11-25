/// What the cat is currently doing.
enum CatActivity {
  idle('Idle'),
  walking('Walking'),
  sitting('Sitting'),
  sleeping('Sleeping'),
  playing('Playing'),
  eating('Eating');

  const CatActivity(this.label);

  final String label;
}