class CompanyMock {
  final int id;
  final String name;

  const CompanyMock({required this.id, required this.name});
}

/// Temporary dummy companies list. Later this will come from API.
const List<CompanyMock> mockCompanies = <CompanyMock>[
  CompanyMock(id: 101, name: 'Demo Company 101'),
  CompanyMock(id: 102, name: 'Demo Company 102'),
  CompanyMock(id: 103, name: 'Demo Company 103'),
];
