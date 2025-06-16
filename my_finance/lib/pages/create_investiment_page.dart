import 'package:flutter/material.dart';
import 'package:my_finance/models/investiment_item.dart';
import '../main.dart';

class CreateInvestmentPage extends StatefulWidget {
  const CreateInvestmentPage({super.key});

  @override
  State<CreateInvestmentPage> createState() => _CreateInvestmentPageState();
}

class _CreateInvestmentPageState extends State<CreateInvestmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _brokerController = TextEditingController();
  String _selectedType = 'Ações';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _brokerController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveInvestment() async {
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

      final newInvestment = InvestmentItem(
        name: _nameController.text.trim(),
        amount: normalizedAmount,
        date: _selectedDate,
        type: _selectedType,
        broker: _brokerController.text.trim(),
      );

      await investmentBox.add(newInvestment);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Investimento salvo com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar investimento: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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
        title: const Text('Novo Investimento'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Preencha os dados do investimento:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Instituição',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome da instituição';
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
                  labelText: 'Valor Investido',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  helperText: 'Use vírgula ou ponto para decimais (ex: 10,50)',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Investimento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.trending_up),
                ),
                items: const [
                  DropdownMenuItem(value: 'Ações', child: Text('Ações')),
                  DropdownMenuItem(value: 'FIIs', child: Text('FIIs')),
                  DropdownMenuItem(value: 'Tesouro Direto', child: Text('Tesouro Direto')),
                  DropdownMenuItem(value: 'CDB/CDI', child: Text('CDB/CDI')),
                  DropdownMenuItem(value: 'Renda Fixa', child: Text('Renda Fixa')),
                  DropdownMenuItem(value: 'Bolsa Bovespa', child: Text('Bolsa Bovespa')),
                  DropdownMenuItem(value: 'Bolsa Nasdaq', child: Text('Bolsa Nasdaq')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _brokerController,
                decoration: const InputDecoration(
                  labelText: 'Corretora (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 16),
              
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.purple),
                  title: const Text('Data do Investimento'),
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
                onPressed: _isLoading ? null : _saveInvestment,
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
                        'Salvar Investimento',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}