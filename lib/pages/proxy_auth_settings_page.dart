import 'package:flutter/material.dart';
import '../models/proxy_credentials.dart';
import '../services/proxy_credentials_service.dart';

/// プロキシ認証情報の入力・編集画面
class ProxyAuthSettingsPage extends StatefulWidget {
  final SecureStorage storage;

  const ProxyAuthSettingsPage({
    Key? key,
    required this.storage,
  }) : super(key: key);

  @override
  State<ProxyAuthSettingsPage> createState() => _ProxyAuthSettingsPageState();
}

class _ProxyAuthSettingsPageState extends State<ProxyAuthSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late ProxyCredentialsService _credentialsService;
  ProxyAuthType _authType = ProxyAuthType.basic;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _credentialsService = ProxyCredentialsService(widget.storage);
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final credentials = await _credentialsService.getCredentials();
      if (mounted) {
        setState(() {
          _usernameController.text = credentials.username;
          _passwordController.text = credentials.password;
          // noneの場合はbasicに変更
          _authType = credentials.authType == ProxyAuthType.none 
              ? ProxyAuthType.basic 
              : credentials.authType;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('認証情報の読み込みに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveCredentials() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credentials = ProxyCredentials(
        username: _usernameController.text,
        password: _passwordController.text,
        authType: _authType,
      );

      await _credentialsService.saveCredentials(credentials);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('認証情報を保存しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCredentials() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('保存されている認証情報を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _credentialsService.deleteCredentials();
        
        if (mounted) {
          setState(() {
            _usernameController.clear();
            _passwordController.clear();
            _authType = ProxyAuthType.basic;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('認証情報を削除しました'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('削除に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('プロキシ認証設定'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : _deleteCredentials,
            tooltip: '認証情報を削除',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 説明カード
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'プロキシ認証が必要な場合は、ユーザー名とパスワードを入力してください。',
                                style: TextStyle(color: Colors.blue[900]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ユーザー名入力
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'ユーザー名',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        hintText: 'プロキシのユーザー名を入力',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ユーザー名を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // パスワード入力
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'パスワード',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        hintText: 'プロキシのパスワードを入力',
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'パスワードを入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 認証方式選択
                    DropdownButtonFormField<ProxyAuthType>(
                      value: _authType,
                      decoration: const InputDecoration(
                        labelText: '認証方式',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.security),
                      ),
                      items: ProxyAuthType.values
                          .where((type) => type != ProxyAuthType.none)
                          .map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getAuthTypeName(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _authType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // 保存ボタン
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveCredentials,
                      icon: const Icon(Icons.save),
                      label: const Text('保存'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // セキュリティに関する注意書き
                    Card(
                      color: Colors.orange[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'セキュリティに関する注意',
                                    style: TextStyle(
                                      color: Colors.orange[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '認証情報は暗号化されて安全に保存されます。',
                                    style: TextStyle(color: Colors.orange[900]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getAuthTypeName(ProxyAuthType type) {
    switch (type) {
      case ProxyAuthType.basic:
        return 'Basic認証';
      case ProxyAuthType.digest:
        return 'Digest認証';
      case ProxyAuthType.ntlm:
        return 'NTLM認証';
      case ProxyAuthType.kerberos:
        return 'Kerberos認証';
      case ProxyAuthType.none:
        return '認証なし';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

