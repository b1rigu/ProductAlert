import 'package:flutter/material.dart';
import 'package:productalert/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseApi {
  static Future<void> updateFCMToken(
    String? token,
    BuildContext context,
  ) async {
    try {
      if (supabase.auth.currentSession == null) {
        throw Exception("User is not logged in");
      }

      final userId = supabase.auth.currentSession!.user.id;
      await supabase.from('profiles').update({
        'fcm_token': token,
      }).eq("id", userId);
    } on PostgrestException catch (error) {
      if (context.mounted) {
        context.showSnackBar(error.message, isError: true);
      }
    } catch (error) {
      if (context.mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(
      BuildContext context) async {
    try {
      if (supabase.auth.currentSession == null) {
        throw Exception("User is not logged in");
      }

      final userId = supabase.auth.currentSession!.user.id;
      final data =
          await supabase.from('profiles').select().eq('id', userId).single();
      return data;
    } on PostgrestException catch (error) {
      if (context.mounted) {
        context.showSnackBar(error.message, isError: true);
      }
      return {};
    } catch (error) {
      if (context.mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
      return {};
    }
  }

  static Future<void> insertDataToDatabase(
    String tableName,
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    try {
      if (supabase.auth.currentSession == null) {
        throw Exception("User is not logged in");
      }

      await supabase.from(tableName).insert(data);

      if (context.mounted) {
        context.showSnackBar("$tableName created successfully");
      }
    } on PostgrestException catch (error) {
      if (context.mounted) {
        context.showSnackBar(error.message, isError: true);
      }
    } catch (error) {
      if (context.mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    }
  }

  static Future<void> deleteDataFromDatabaseByField(
    String tableName,
    String field,
    dynamic value,
    BuildContext context,
  ) async {
    try {
      if (supabase.auth.currentSession == null) {
        throw Exception("User is not logged in");
      }

      await supabase.from(tableName).delete().eq(field, value);

      if (context.mounted) {
        context.showSnackBar("$tableName deleted successfully");
      }
    } on PostgrestException catch (error) {
      if (context.mounted) {
        context.showSnackBar(error.message, isError: true);
      }
    } catch (error) {
      if (context.mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    }
  }

  static Future<void> logout(BuildContext context) async {
    try {
      updateFCMToken(null, context);
      supabase.auth.signOut();
      firebaseMessaging.deleteToken();
    } on PostgrestException catch (error) {
      if (context.mounted) {
        context.showSnackBar(error.message, isError: true);
      }
    } catch (error) {
      if (context.mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    }
  }
}
