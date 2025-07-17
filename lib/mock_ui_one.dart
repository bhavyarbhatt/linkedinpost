import 'package:flutter/material.dart';
import 'package:device_frame/device_frame.dart';

void main() {
  runApp(FinanceMockupApp());
}

class FinanceMockupApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance App Mockup',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      home: MockupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MockupScreen extends StatefulWidget {
  @override
  _MockupScreenState createState() => _MockupScreenState();
}

class _MockupScreenState extends State<MockupScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationController.repeat();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.blue.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateY(_rotationAnimation.value * 2 * 3.14159 * 0.1),
                  child: DeviceFrame(
                    device: Devices.ios.iPhone13ProMax,
                    screen: FinanceApp(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scaleController.reset();
          _scaleController.forward();
        },
        child: Icon(Icons.refresh),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;
  final IconData icon;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
    required this.icon,
  });
}

class FinanceApp extends StatefulWidget {
  @override
  _FinanceAppState createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp>
    with TickerProviderStateMixin {
  bool _isBalanceVisible = true;
  double _currentBalance = 12847.50;
  double _monthlyIncome = 8500.00;
  double _monthlyExpenses = 3247.80;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<Transaction> _transactions = [
    Transaction(
      id: '1',
      title: 'Salary',
      amount: 8500.00,
      category: 'Income',
      date: DateTime.now().subtract(Duration(days: 1)),
      isIncome: true,
      icon: Icons.work,
    ),
    Transaction(
      id: '2',
      title: 'Grocery Shopping',
      amount: 245.80,
      category: 'Food',
      date: DateTime.now().subtract(Duration(days: 2)),
      isIncome: false,
      icon: Icons.shopping_cart,
    ),
    Transaction(
      id: '3',
      title: 'Netflix Subscription',
      amount: 15.99,
      category: 'Entertainment',
      date: DateTime.now().subtract(Duration(days: 3)),
      isIncome: false,
      icon: Icons.movie,
    ),
    Transaction(
      id: '4',
      title: 'Fuel',
      amount: 65.00,
      category: 'Transport',
      date: DateTime.now().subtract(Duration(days: 4)),
      isIncome: false,
      icon: Icons.local_gas_station,
    ),
    Transaction(
      id: '5',
      title: 'Freelance Project',
      amount: 1200.00,
      category: 'Income',
      date: DateTime.now().subtract(Duration(days: 5)),
      isIncome: true,
      icon: Icons.laptop,
    ),
  ];

  List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Colors.orange, 'spent': 335.30},
    {'name': 'Transport', 'icon': Icons.directions_car, 'color': Colors.blue, 'spent': 165.00},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.purple, 'spent': 89.99},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.pink, 'spent': 425.80},
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinanceFlow',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      home: Scaffold(
        backgroundColor: Colors.grey[50],
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildBalanceCard(),
                  _buildQuickActions(),
                  _buildSpendingChart(),
                  _buildCategorySpending(),
                  _buildRecentTransactions(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good ${_getGreeting()}!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Alex Johnson',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: Text(
              _isBalanceVisible ? '\$${_currentBalance.toStringAsFixed(2)}' : '••••••••',
              key: ValueKey(_isBalanceVisible),
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem(
                  'Income',
                  _monthlyIncome,
                  Icons.arrow_upward,
                  Colors.green,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _buildBalanceItem(
                  'Expenses',
                  _monthlyExpenses,
                  Icons.arrow_downward,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, double amount, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            _isBalanceVisible ? '\$${amount.toStringAsFixed(2)}' : '••••••',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionItem('Send', Icons.send, Colors.blue),
              _buildQuickActionItem('Request', Icons.request_page, Colors.green),
              _buildQuickActionItem('Bills', Icons.receipt_long, Colors.orange),
              _buildQuickActionItem('Top Up', Icons.add_card, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingChart() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Spending',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChartBar('M', 80, Colors.deepPurple),
                _buildChartBar('T', 120, Colors.blue),
                _buildChartBar('W', 60, Colors.green),
                _buildChartBar('T', 140, Colors.orange),
                _buildChartBar('F', 100, Colors.pink),
                _buildChartBar('S', 180, Colors.red),
                _buildChartBar('S', 90, Colors.teal),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double amount, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 25,
          height: amount * 0.4,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySpending() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ..._categories.map((category) => _buildCategoryItem(category)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              category['icon'],
              color: category['color'],
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              category['name'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            '\$${category['spent'].toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ..._transactions.take(4).map((transaction) => _buildTransactionItem(transaction)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.isIncome
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.icon,
              color: transaction.isIncome ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  transaction.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: transaction.isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}