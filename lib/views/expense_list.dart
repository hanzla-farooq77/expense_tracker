import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpenseListView extends StatelessWidget {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in first")),
      );
    }

    final userId = currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Expenses',
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('expenses')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error fetching data: ${snapshot.error}'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              });
              return const Center(child: Text("Something went wrong"));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No expenses added yet.',
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
              );
            }

            final expenses = snapshot.data!.docs;

            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 1;
                if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
                  crossAxisCount = 2;
                } else if (constraints.maxWidth >= 900) {
                  crossAxisCount = 3;
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    final data = expense.data() as Map<String, dynamic>;

                    return ExpenseCard(
                      billName: data['BillName'] ?? 'Unknown',
                      amount: data['Amount'] ?? '0.00',
                      billDate: data['BillDate'] ?? 'N/A',
                      note: data['Note'] ?? 'No Note Provided',
                      imageUrl: data['imageUrl'] ?? '',
                      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
                      theme: theme,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ExpenseCard extends StatelessWidget {
  final String billName;
  final String amount;
  final String billDate;
  final String note;
  final String imageUrl;
  final DateTime? createdAt;
  final ThemeData theme;

  const ExpenseCard({
    super.key,
    required this.billName,
    required this.amount,
    required this.billDate,
    required this.note,
    required this.imageUrl,
    required this.createdAt,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: theme.colorScheme.primary.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Image Section
          Expanded(
            flex: 5,
            child: imageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined,
                      size: 50, color: Colors.grey),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                },
              ),
            )
                : Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported_outlined,
                  size: 50, color: Colors.grey),
            ),
          ),

          // 🔹 Details Section
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.05),
                    theme.colorScheme.secondary.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    billName,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onBackground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  Text(
                    '₨ $amount',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 6),
                  Text(
                    note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      createdAt != null
                          ? "Added: ${createdAt!.day}/${createdAt!.month}/${createdAt!.year}"
                          : "Added: N/A",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
