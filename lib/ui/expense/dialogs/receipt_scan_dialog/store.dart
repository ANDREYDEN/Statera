enum Store {
  other(title: 'Other'),
  walmart(title: 'Walmart'),
  lcbo(title: 'LCBO'),
  metro(title: 'Metro');

  const Store({required this.title});

  final String title;
}
