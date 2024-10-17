enum Store {
  other(title: 'Other'),
  walmart(title: 'Walmart'),
  lcbo(title: 'LCBO');

  const Store({required this.title});

  final String title;
}
