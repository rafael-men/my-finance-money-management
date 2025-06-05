import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../data/expense_data.dart';
import '../models/expense_item.dart';

class CreateExpensePage extends StatefulWidget {
  final ExpenseData expenseData;

  const CreateExpensePage({super.key, required this.expenseData});

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final normalizedAmount = _amountController.text.replaceAll(',', '.');
    
      final parsedAmount = double.tryParse(normalizedAmount);
      if (parsedAmount == null || parsedAmount <= 0) {
        throw Exception('Valor inválido');
      }

  
      final newExpense = ExpenseItem(
        name: _nameController.text.trim(),
        amount: normalizedAmount,
        date: _selectedDate,
      );

      print('Tentando salvar expense: ${newExpense.name} - R\$ ${newExpense.amount} - ${newExpense.date}');
      

      await widget.expenseData.addExpense(newExpense);
           

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compra salva com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.pop(context, true);
      }
      
    } catch (e) {
      print('Erro ao salvar expense: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar compra: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Compra'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da compra',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_cart),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome da compra';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  helperText: 'Use vírgula ou ponto para decimais (ex: 10,50)',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o valor';
                  }
                  
                  final normalizedValue = value.replaceAll(',', '.');
                  final val = double.tryParse(normalizedValue);
                  
                  if (val == null) {
                    return 'Valor inválido';
                  }
                  
                  if (val <= 0) {
                    return 'Valor deve ser maior que zero';
                  }
                  
                  if (val > 999999) {
                    return 'Valor muito alto';
                  }
                  
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.purple),
                  title: const Text('Data da compra'),
                  subtitle: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/'
                    '${_selectedDate.month.toString().padLeft(2, '0')}/'
                    '${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: TextButton(
                    onPressed: _pickDate,
                    child: const Text('Alterar'),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Salvar Compra',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}