import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import '../../core/services/search_service.dart';
import '../../core/utils/category_helper.dart';
import '../../core/utils/currency_helper.dart';
import '../../core/utils/date_helper.dart';
import 'transaction_controller.dart';
import 'transaction_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TransactionController controller;
  final searchController = TextEditingController();
  
  // Filter variables
  DateTime? startDate;
  DateTime? endDate;
  String? selectedCategory;
  bool? selectedType; // null = tất cả, true = chi, false = thu
  double? minAmount;
  double? maxAmount;
  String sortBy = 'date'; // date, amount, name
  bool sortAscending = false;

  List<Transaction> searchResults = [];
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Try to find existing controller, if not create a new one
    try {
      controller = Get.find<TransactionController>();
    } catch (e) {
      controller = Get.put(TransactionController());
    }
    _loadInitialData();
  }

  void _loadInitialData() {
    searchResults = controller.transactionList.toList();
  }

  void _performSearch() {
    if (searchController.text.isEmpty && 
        startDate == null && 
        selectedCategory == null && 
        selectedType == null &&
        minAmount == null &&
        maxAmount == null) {
      setState(() {
        searchResults = controller.transactionList.toList();
        hasSearched = false;
      });
      return;
    }

    List<Transaction> results = SearchService.advancedSearch(
      controller.transactionList,
      keyword: searchController.text.isNotEmpty ? searchController.text : null,
      startDate: startDate,
      endDate: endDate,
      categoryId: selectedCategory,
      isExpense: selectedType,
      minAmount: minAmount,
      maxAmount: maxAmount,
    );

    results = SearchService.searchWithSort(results, sortBy, isAscending: sortAscending);

    setState(() {
      searchResults = results;
      hasSearched = true;
    });
  }

  void _clearFilters() {
    setState(() {
      searchController.clear();
      startDate = null;
      endDate = null;
      selectedCategory = null;
      selectedType = null;
      minAmount = null;
      maxAmount = null;
      sortBy = 'date';
      sortAscending = false;
      searchResults = controller.transactionList.toList();
      hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD54F),
        title: const Text(
          "Tìm kiếm",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          child: Column(
            children: [
              // ===== SEARCH BOX =====
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm ghi chú, danh mục...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              _performSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),

              // ===== FILTER BUTTONS =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: [
                    // Ngày
                    FilterChip(
                      label: Text(
                        startDate != null && endDate != null
                            ? "${DateHelper.formatDate(startDate!)} - ${DateHelper.formatDate(endDate!)}"
                            : "Ngày",
                      ),
                      onSelected: (_) => _showDateRangeDialog(),
                      backgroundColor: startDate != null ? const Color(0xFFFFD54F) : null,
                    ),
                    // Danh mục
                    FilterChip(
                      label: Text(selectedCategory != null
                          ? CategoryHelper.getCategoryById(selectedCategory!).name
                          : "Danh mục"),
                      onSelected: (_) => _showCategoryDialog(),
                      backgroundColor: selectedCategory != null ? const Color(0xFFFFD54F) : null,
                    ),
                    // Loại
                    FilterChip(
                      label: Text(selectedType == null
                          ? "Loại"
                          : (selectedType! ? "Chi" : "Thu")),
                      onSelected: (_) => _showTypeDialog(),
                      backgroundColor: selectedType != null ? const Color(0xFFFFD54F) : null,
                    ),
                  ],
                ),
              ),

              // ===== ADVANCED FILTERS (Expandable) =====
              ExpansionTile(
                title: const Text("Bộ lọc nâng cao"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Khoảng số tiền
                        const Text("Khoảng số tiền", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Tối thiểu",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  minAmount = double.tryParse(value);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Tối đa",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  maxAmount = double.tryParse(value);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Sắp xếp
                        const Text("Sắp xếp", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButton<String>(
                                value: sortBy,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 'date', child: Text('Theo ngày')),
                                  DropdownMenuItem(value: 'amount', child: Text('Theo số tiền')),
                                  DropdownMenuItem(value: 'name', child: Text('Theo ghi chú')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => sortBy = value);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                setState(() => sortAscending = !sortAscending);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD54F),
                              ),
                              child: Icon(
                                sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ===== ACTION BUTTONS =====
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _performSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD54F),
                        ),
                        child: const Text(
                          "Tìm kiếm",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _clearFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text("Xóa", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),

              // ===== RESULTS =====
              if (hasSearched)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Tìm thấy ${searchResults.length} kết quả",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final transaction = searchResults[index];
                  final category = CategoryHelper.getCategoryById(transaction.category);

                  return InkWell(
                    onTap: () {
                      Get.to(
                        () => TransactionDetailScreen(transaction: transaction),
                        transition: Transition.rightToLeft,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: category.color.withOpacity(0.2),
                            child: Icon(category.icon, color: category.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.note,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  DateHelper.formatDate(transaction.date),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${transaction.isExpense ? '-' : '+'}${CurrencyHelper.format(transaction.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: transaction.isExpense ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              if (hasSearched && searchResults.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        "Không tìm thấy kết quả",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  void _showDateRangeDialog() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    ).then((range) {
      if (range != null) {
        setState(() {
          startDate = range.start;
          endDate = range.end;
        });
      }
    });
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) {
          final searchController = TextEditingController();
          List<Category> filteredCategories = CategoryHelper.getAllCategories();

          return AlertDialog(
            title: const Text("Chọn danh mục"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Thanh tìm kiếm
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm danh mục...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onChanged: (value) {
                      dialogSetState(() {
                        if (value.isEmpty) {
                          filteredCategories = CategoryHelper.getAllCategories();
                        } else {
                          filteredCategories = CategoryHelper.searchAllCategoriesByKeyword(value);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Danh sách danh mục
                  ListTile(
                    title: const Text("Tất cả"),
                    onTap: () {
                      setState(() => selectedCategory = null);
                      Get.back();
                    },
                  ),
                  ...filteredCategories.map((cat) {
                    return ListTile(
                      leading: Icon(cat.icon, color: cat.color),
                      title: Text(cat.name),
                      subtitle: cat.keywords.isNotEmpty 
                          ? Text(
                              cat.keywords.join(', '),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () {
                        setState(() => selectedCategory = cat.id);
                        Get.back();
                      },
                    );
                  }).toList(),
                  
                  // Thông báo khi không tìm thấy
                  if (filteredCategories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off, size: 32, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              "Không tìm thấy danh mục",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Loại giao dịch"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Tất cả"),
              onTap: () {
                setState(() => selectedType = null);
                Get.back();
              },
            ),
            ListTile(
              title: const Text("Chi tiêu"),
              onTap: () {
                setState(() => selectedType = true);
                Get.back();
              },
            ),
            ListTile(
              title: const Text("Thu nhập"),
              onTap: () {
                setState(() => selectedType = false);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
