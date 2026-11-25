/// The player's coin balance. The balance can never go negative.
class CoinWallet {
  CoinWallet({int initialBalance = 0})
      : _balance = initialBalance < 0 ? 0 : initialBalance;

  int _balance;

  int get balance => _balance;

  bool canAfford(int amount) => amount >= 0 && amount <= _balance;

  /// Adds [amount] coins. Throws [ArgumentError] if [amount] is negative.
  void add(int amount) {
    _checkNotNegative(amount);
    _balance += amount;
  }

  /// Spends [amount] coins if the player can afford it.
  /// Returns false (and changes nothing) if the balance is too low.
  /// Throws [ArgumentError] if [amount] is negative.
  bool trySpend(int amount) {
    _checkNotNegative(amount);
    if (amount > _balance) return false;
    _balance -= amount;
    return true;
  }

  void _checkNotNegative(int amount) {
    if (amount < 0) {
      throw ArgumentError.value(amount, 'amount', 'must not be negative');
    }
  }
}
