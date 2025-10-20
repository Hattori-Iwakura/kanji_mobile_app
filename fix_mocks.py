#!/usr/bin/env python3
"""
Quick script to fix mock patterns in test files.
Converts:
  mockUseCase(param: value) -> mockUseCase.call(param: anyNamed('param'))
  mockUseCase(value) -> mockUseCase.call(any)
"""

import re
import sys

def fix_flashcard_file():
    """Fix flashcard_bloc_test.dart"""
    filepath = 'test/features/flashcard/presentation/bloc/flashcard_bloc_test.dart'
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix patterns
    replacements = [
        # GetDeckByIdUseCase - positional
        (r'mockGetDeckByIdUseCase\((\d+|any)\)', r'mockGetDeckByIdUseCase.call(any)'),
        # CreateDeckUseCase - named params
        (r'mockCreateDeckUseCase\(\s*name:\s*any,\s*description:\s*any,\s*kanjiIds:\s*any\s*\)', 
         r'mockCreateDeckUseCase.call(name: anyNamed(\'name\'), description: anyNamed(\'description\'), kanjiIds: anyNamed(\'kanjiIds\'))'),
        (r'mockCreateDeckUseCase\(\s*name:\s*\'([^\']*)\',\s*description:\s*\'([^\']*)\',\s*kanjiIds:\s*([^\)]+)\)',
         r'mockCreateDeckUseCase.call(name: anyNamed(\'name\'), description: anyNamed(\'description\'), kanjiIds: anyNamed(\'kanjiIds\'))'),
        (r'mockCreateDeckUseCase\(\s*name:\s*\'\',\s*description:\s*any,\s*kanjiIds:\s*any\)',
         r'mockCreateDeckUseCase.call(name: anyNamed(\'name\'), description: anyNamed(\'description\'), kanjiIds: anyNamed(\'kanjiIds\'))'),
        # UpdateDeckUseCase - named params
        (r'mockUpdateDeckUseCase\(\s*id:\s*(\d+|any),\s*name:\s*([^,]+),\s*description:\s*([^,]+),\s*isPublic:\s*([^\)]+)\)',
         r'mockUpdateDeckUseCase.call(id: anyNamed(\'id\'), name: anyNamed(\'name\'), description: anyNamed(\'description\'), isPublic: anyNamed(\'isPublic\'))'),
        # DeleteDeckUseCase - positional
        (r'mockDeleteDeckUseCase\((\d+|any)\)', r'mockDeleteDeckUseCase.call(any)'),
        # AddCardUseCase - named params
        (r'mockAddCardUseCase\(\s*deckId:\s*(\d+|any),\s*kanjiId:\s*(\d+|any)\)',
         r'mockAddCardUseCase.call(deckId: anyNamed(\'deckId\'), kanjiId: anyNamed(\'kanjiId\'))'),
        # RemoveCardUseCase - named params
        (r'mockRemoveCardUseCase\(\s*deckId:\s*(\d+|any),\s*kanjiId:\s*(\d+|any)\)',
         r'mockRemoveCardUseCase.call(deckId: anyNamed(\'deckId\'), kanjiId: anyNamed(\'kanjiId\'))'),
        # RequestPublishUseCase - positional
        (r'mockRequestPublishUseCase\((\d+|any)\)', r'mockRequestPublishUseCase.call(any)'),
        # GetPublishRequestsUseCase - named param
        (r'mockGetPublishRequestsUseCase\(\s*status:\s*([^\)]+)\)',
         r'mockGetPublishRequestsUseCase.call(status: anyNamed(\'status\'))'),
        # ApprovePublishRequestUseCase - positional
        (r'mockApprovePublishRequestUseCase\((\d+|any)\)', r'mockApprovePublishRequestUseCase.call(any)'),
        # RejectPublishRequestUseCase - 2 params
        (r'mockRejectPublishRequestUseCase\((\d+|any),\s*([^\)]+)\)',
         r'mockRejectPublishRequestUseCase.call(any, any)'),
    ]
    
    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f'Fixed {filepath}')

if __name__ == '__main__':
    fix_flashcard_file()
    print('Done!')
