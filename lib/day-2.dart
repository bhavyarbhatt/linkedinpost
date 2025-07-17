import 'package:flutter/material.dart';
import 'package:device_frame/device_frame.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rotating iPhone Finance UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RotatingPhoneDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RotatingPhoneDemo extends StatefulWidget {
  @override
  _RotatingPhoneDemoState createState() => _RotatingPhoneDemoState();
}

class _RotatingPhoneDemoState extends State<RotatingPhoneDemo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scrollController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scrollAnimation;

  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Slow 3D rotation animation (30 seconds per full rotation)
    _rotationController = AnimationController(
      duration: Duration(seconds: 30),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Auto-scroll animation (10 seconds per cycle)
    _scrollController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    );

    _scrollAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scrollController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _rotationController.repeat();
    _scrollController.repeat(reverse: true);

    // Listen to scroll animation to auto-scroll the finance UI
    _scrollAnimation.addListener(() {
      if (_pageScrollController.hasClients) {
        final maxScroll = _pageScrollController.position.maxScrollExtent;
        final targetScroll = maxScroll * _scrollAnimation.value;
        _pageScrollController.animateTo(
          targetScroll,
          duration: Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scrollController.dispose();
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        margin: EdgeInsets.all(50), // Added margin as requested
        child: Center(
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY(_rotationAnimation.value * 0.3) // Slow Y rotation
                  ..rotateX(math.sin(_rotationAnimation.value) * 0.1) // Subtle X rotation
                  ..rotateZ(_rotationAnimation.value * 0.1), // Subtle Z rotation
                child: Container(
                  width: 300,
                  height: 650,
                  child: DeviceFrame(
                    device: Devices.ios.iPhone13,
                    screen: FinanceUI(scrollController: _pageScrollController),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class FinanceUI extends StatelessWidget {
  final ScrollController scrollController;

  const FinanceUI({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'John Doe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Balance Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '\$24,567.89',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBalanceItem('Income', '\$12,345', Colors.green),
                      _buildBalanceItem('Expenses', '\$8,765', Colors.red),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Actions
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickAction(Icons.send, 'Send', Colors.blue),
                      _buildQuickAction(Icons.receipt, 'Request', Colors.green),
                      _buildQuickAction(Icons.phone, 'Top Up', Colors.orange),
                      _buildQuickAction(Icons.more_horiz, 'More', Colors.grey),
                    ],
                  ),
                ],
              ),
            ),

            // Recent Transactions
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  _buildTransaction('Netflix', 'Subscription', '-\$12.99', Colors.red),
                  _buildTransaction('Salary', 'Monthly Income', '+\$3,500', Colors.green),
                  _buildTransaction('Spotify', 'Music Subscription', '-\$9.99', Colors.red),
                  _buildTransaction('Freelance', 'Design Work', '+\$850', Colors.green),
                  _buildTransaction('Grocery', 'Food & Beverages', '-\$127.50', Colors.red),
                  _buildTransaction('Investment', 'Stock Dividend', '+\$45.20', Colors.green),
                  _buildTransaction('Electricity', 'Monthly Bill', '-\$89.30', Colors.red),
                  _buildTransaction('Bonus', 'Performance Bonus', '+\$1,200', Colors.green),
                ],
              ),
            ),

            // Spending Analytics
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF16213E),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Analytics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildSpendingCategory('Food & Dining', 35, Colors.orange),
                  _buildSpendingCategory('Transportation', 25, Colors.blue),
                  _buildSpendingCategory('Shopping', 20, Colors.purple),
                  _buildSpendingCategory('Entertainment', 15, Colors.green),
                  _buildSpendingCategory('Others', 5, Colors.grey),
                ],
              ),
            ),

            // Investment Portfolio
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF16213E),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Investment Portfolio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildInvestmentItem('AAPL', 'Apple Inc.', '\$156.23', '+2.45%', Colors.green),
                  _buildInvestmentItem('GOOGL', 'Google LLC', '\$2,847.32', '+1.23%', Colors.green),
                  _buildInvestmentItem('TSLA', 'Tesla Inc.', '\$891.45', '-0.87%', Colors.red),
                  _buildInvestmentItem('AMZN', 'Amazon.com', '\$3,234.56', '+0.92%', Colors.green),
                ],
              ),
            ),

            SizedBox(height: 100), // Extra space for scrolling
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String title, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String title, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 25),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTransaction(String title, String subtitle, String amount, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  amount.startsWith('+') ? Icons.arrow_upward : Icons.arrow_downward,
                  color: color,
                  size: 20,
                ),
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingCategory(String category, int percentage, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentItem(String symbol, String name, String price, String change, Color changeColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  symbol,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            change,
            style: TextStyle(
              color: changeColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}