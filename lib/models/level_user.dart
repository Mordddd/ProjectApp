enum LevelUser {
  admin(id: 1, code: 'admin', label: 'Admin'),
  supervisor(id: 2, code: 'supervisor', label: 'Supervisor'),
  stafCustomer(id: 3, code: 'staf_customer', label: 'Staf Customer'),
  customer(id: 4, code: 'customer', label: 'Customer');

  final int id;
  final String code;
  final String label;

  const LevelUser({required this.id, required this.code, required this.label});

  static LevelUser fromId(int id) {
    return LevelUser.values.firstWhere(
      (level) => level.id == id,
      orElse: () => LevelUser.customer,
    );
  }

  static LevelUser fromCode(String code) {
    final normalized = code.trim().toLowerCase();
    return LevelUser.values.firstWhere(
      (level) => level.code == normalized,
      orElse: () => LevelUser.customer,
    );
  }

  bool get isAdmin => this == LevelUser.admin;
}
