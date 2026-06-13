import 'package:flutter/material.dart';
import '../widgets/app_components.dart';

class SortingPage extends StatefulWidget {
  const SortingPage({super.key});

  @override
  State<SortingPage> createState() => _SortingPageState();
}

class _SortingPageState extends State<SortingPage> {
  final TextEditingController controller = TextEditingController();

  Map<String, String> results = {};

  void processSorting() {
    final numbers = controller.text
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();

    if (numbers.length != 10) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Masukkan tepat 10 angka")));
      return;
    }

    setState(() {
      results = {
        "Bubble Sort": generateResult(
          bubbleSort(numbers),
          bubbleSort(numbers, desc: true),
        ),
        "Selection Sort": generateResult(
          selectionSort(numbers),
          selectionSort(numbers, desc: true),
        ),
        "Insertion Sort": generateResult(
          insertionSort(numbers),
          insertionSort(numbers, desc: true),
        ),
        "Merge Sort": generateResult(
          mergeSort(numbers),
          mergeSort(numbers, desc: true),
        ),
        "Quick Sort": generateResult(
          quickSort(numbers),
          quickSort(numbers, desc: true),
        ),
      };
    });
  }

  String generateResult(List<int> asc, List<int> desc) {
    return "Ascending:\n${asc.join(', ')}\n\nDescending:\n${desc.join(', ')}";
  }

  List<int> bubbleSort(List<int> data, {bool desc = false}) {
    List<int> arr = List.from(data);

    for (int i = 0; i < arr.length - 1; i++) {
      for (int j = 0; j < arr.length - i - 1; j++) {
        if ((!desc && arr[j] > arr[j + 1]) || (desc && arr[j] < arr[j + 1])) {
          int temp = arr[j];
          arr[j] = arr[j + 1];
          arr[j + 1] = temp;
        }
      }
    }

    return arr;
  }

  List<int> selectionSort(List<int> data, {bool desc = false}) {
    List<int> arr = List.from(data);

    for (int i = 0; i < arr.length - 1; i++) {
      int index = i;

      for (int j = i + 1; j < arr.length; j++) {
        if ((!desc && arr[j] < arr[index]) || (desc && arr[j] > arr[index])) {
          index = j;
        }
      }

      int temp = arr[i];
      arr[i] = arr[index];
      arr[index] = temp;
    }

    return arr;
  }

  List<int> insertionSort(List<int> data, {bool desc = false}) {
    List<int> arr = List.from(data);

    for (int i = 1; i < arr.length; i++) {
      int key = arr[i];
      int j = i - 1;

      while (j >= 0 && ((!desc && arr[j] > key) || (desc && arr[j] < key))) {
        arr[j + 1] = arr[j];
        j--;
      }

      arr[j + 1] = key;
    }

    return arr;
  }

  List<int> mergeSort(List<int> arr, {bool desc = false}) {
    if (arr.length <= 1) return arr;

    int mid = arr.length ~/ 2;

    List<int> left = mergeSort(arr.sublist(0, mid), desc: desc);

    List<int> right = mergeSort(arr.sublist(mid), desc: desc);

    return merge(left, right, desc);
  }

  List<int> merge(List<int> left, List<int> right, bool desc) {
    List<int> result = [];

    while (left.isNotEmpty && right.isNotEmpty) {
      if ((!desc && left.first <= right.first) ||
          (desc && left.first >= right.first)) {
        result.add(left.removeAt(0));
      } else {
        result.add(right.removeAt(0));
      }
    }

    result.addAll(left);
    result.addAll(right);

    return result;
  }

  List<int> quickSort(List<int> arr, {bool desc = false}) {
    if (arr.length <= 1) return arr;

    int pivot = arr[arr.length ~/ 2];

    List<int> left = [];
    List<int> middle = [];
    List<int> right = [];

    for (var n in arr) {
      if ((!desc && n < pivot) || (desc && n > pivot)) {
        left.add(n);
      } else if (n == pivot) {
        middle.add(n);
      } else {
        right.add(n);
      }
    }

    return [
      ...quickSort(left, desc: desc),
      ...middle,
      ...quickSort(right, desc: desc),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text("Sorting")),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          CustomCard(
            color: AppPalette.navy,
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            child: Row(
              children: [
                IconBubble(
                  icon: Icons.sort_rounded,
                  color: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    "Sorting",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          CustomCard(
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: "Masukkan 10 angka (pisahkan koma)",
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: processSorting,
                  child: const Text("Proses Sorting"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: results.isEmpty
                ? CustomCard(
                    key: const ValueKey('empty'),
                    child: Text(
                      "Hasil sorting akan tampil di sini.",
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  )
                : Column(
                    key: ValueKey(results.length),
                    children: results.entries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CustomCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.key,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(e.value),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
