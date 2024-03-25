"""
Test custom django management commands
"""

from unittest.mock import patch
from psycopg2 import OperationalError as Psycopg2Error
from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase


@patch('core.management.commands.wait_for_db.Command.check')
class CommandTests(SimpleTestCase):
    """Test commands"""

    def test_wait_for_db_ready(self, patched_check):
        """Test waiting for database (db is ready)"""
        patched_check.return_value = True
        call_command('wait_for_db')
        patched_check.assert_called_once_with(databases=['default'])

    # applies patches from the inside out, so need to list patched_sleep
    # as the first arg, etc
    @patch('time.sleep')
    def test_wait_for_db_delay(self, patched_sleep, patched_check):
        """Test waiting for database (db is not ready, operational error)"""
        # raise psycopg error first 2 times, then 3 operational errors,
        # then finally true (defines behavior for repeated calls)
        patched_check.side_effect = ([Psycopg2Error] * 2 +
                                     [OperationalError] * 3 + [True])
        call_command('wait_for_db')
        self.assertEqual(patched_check.call_count, 6)
        patched_check.assert_called_with(databases=['default'])
